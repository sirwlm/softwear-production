# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'

require 'rspec/rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

require 'database_cleaner'
require 'ffaker'

require 'paperclip/matchers'

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.color = true
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # A workaround to deal with random failure caused by phantomjs. Turn it on
  # by setting ENV['RSPEC_RETRY_COUNT']. Limit it to features tests where
  # phantomjs is used.
  config.before(:all, :type => :feature) do
    if ENV['RSPEC_RETRY_COUNT']
      config.verbose_retry       = true # show retry status in spec process
      config.default_retry_count = ENV['RSPEC_RETRY_COUNT'].to_i
    end
  end

  config.before :suite do
    Capybara.match = :prefer_exact
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    Rails.cache.clear
    WebMock.disable!
    if RSpec.current_example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    # TODO: Find out why open_transactions ever gets below 0
    # See issue #3428
    if ActiveRecord::Base.connection.open_transactions < 0
      ActiveRecord::Base.connection.increment_open_transactions
    end

    DatabaseCleaner.start
    reset_spree_preferences
  end

  config.after(:each) do
    # Ensure js requests finish processing before advancing to the next test
    wait_for_ajax if RSpec.current_example.metadata[:js]

    DatabaseCleaner.clean
  end

  config.after(:each, :type => :feature) do
    missing_translations = page.body.scan(/translation missing: #{I18n.locale}\.(.*?)[\s<\"&]/)
    if missing_translations.any?
      puts "Found missing translations: #{missing_translations.inspect}"
      puts "In spec: #{example.location}"
    end
  end

  config.include FactoryGirl::Syntax::Methods

  config.include Paperclip::Shoulda::Matchers

  config.extend WithModel

  config.fail_fast = ENV['FAIL_FAST'] || false
end