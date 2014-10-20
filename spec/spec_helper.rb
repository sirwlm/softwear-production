# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.color = true
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # Use chrome instead of firefox
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end

  # A workaround to deal with random failure caused by phantomjs. Turn it on
  # by setting ENV['RSPEC_RETRY_COUNT']. Limit it to features tests where
  # phantomjs is used.
  config.before(:all, :type => :feature) do
    WebMock.disable!
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
    if RSpec.current_example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end

    if ActiveRecord::Base.connection.open_transactions < 0
      ActiveRecord::Base.connection.increment_open_transactions
    end

    DatabaseCleaner.start
  end

  config.after(:each) do
    # Ensure js requests finish processing before advancing to the next test
    wait_for_ajax if RSpec.current_example.metadata[:js]

    DatabaseCleaner.clean
  end


  config.include FactoryGirl::Syntax::Methods
  config.infer_spec_type_from_file_location!
end
