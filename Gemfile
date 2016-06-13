source 'https://rubygems.org'

gem 'softwear-lib', '~> 1.7.11'

gem 'jbuilder', '~> 1.2'
gem 'state_machines-activerecord'
gem 'cancan'
gem 'jquery-tablesorter', '~> 1.16.5'

group :development, :test do
# used to graph state machines
  gem 'ruby-graphviz', require: 'graphviz'
# used to sexily print tables in rails console
  gem 'mailcatcher'
end

group :test do
  gem 'database_cleaner', '~> 1.0'
  gem 'launchy'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'rspec-expectations'
  gem 'simplecov'
  gem 'poltergeist', '1.5.0'
  gem 'timecop'
  gem 'with_model'
  gem 'endpoint_stub', github: 'AnnArborTees/endpoint_stub', branch: 'develop'
  gem 'state_machines-activemodel'
  gem 'capybara-select2'
  gem 'test_after_commit'
  gem 'fakeredis', :require => 'fakeredis/rspec'
end

gem 'nested_form'
gem 'x-editable-rails'
gem 'safe_yaml', '~> 1.0.4'
gem 'autoprefixer-rails'
gem 'bootstrap-colorpicker-rails'
gem 'fullcalendar-rails', '~> 2.2.5.0'
gem 'friendly_id', '~> 5.0.0'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'sunspot_matchers'
gem 'select2-rails', git: 'git://github.com/argerim/select2-rails'
gem 'public_activity', github: 'AnnArborTees/public_activity'
gem 'bootstrap-kaminari-views'
gem 'twitter-typeahead-rails'
gem 'bootstrap-wysihtml5-rails', github: 'nerian/bootstrap-wysihtml5-rails'
gem 'progress_bar'
gem 'sidekiq', github: 'mperham/sidekiq'
gem 'sidekiq-status'
gem 'sidekiq-failures', github: 'AnnArborTees/sidekiq-failures'
gem 'sinatra', require: false
gem 'redis-namespace'
gem 'cap-ec2', group: :development

# === BEGIN SOFTWEAR LIB GEMS === #

gem 'rails', '~> 4.2.3'

gem 'mysql2'
gem 'sass-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'bootstrap-sass', '~> 3.2.0'
gem 'activeresource'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'hirb'
gem 'momentjs-rails', '~> 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '4.7.14'
gem 'js-routes'
gem 'inherited_resources'
gem 'devise'
gem 'figaro'
gem 'paranoia', '~> 2.0'
gem 'paperclip'
gem 'kaminari'
gem 'whenever'
gem 'dumpsync', git: 'git://github.com/AnnArborTees/dumpsync.git'
gem 'bootstrap_form'
gem 'acts_as_warnable', git: 'git://github.com/AnnArborTees/acts_as_warnable.git'
gem 'simple_token_authentication'

group :development do
  gem 'capistrano', '~> 3.2.0'
  gem 'capistrano-rails'
  gem 'capistrano-rvm', github: 'AnnArborTees/rvm'
  gem 'capistrano-bundler', github: 'AnnArborTees/bundler'
  gem 'better_errors', '>= 0.3.2'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'byebug', platforms: :mri
  gem 'rubinius-debugger', platforms: :rbx
end

group :test do
  gem "rspec-rails", "~> 3.2.0"
  gem 'factory_girl_rails', '>= 4.2.0', require: true
  gem 'capybara', '~> 2.4'
  gem 'capybara-webkit'
  gem 'webmock', require: false
  gem 'rspec-mocks'
  gem 'rspec-retry'
  gem 'email_spec'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
end
# === END SOFTWEAR LIB GEMS === #
