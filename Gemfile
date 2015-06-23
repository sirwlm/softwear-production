source 'https://rubygems.org'

# gem 'softwear-lib'
require 'softwear/lib'
Softwear::Lib.common_gems(self)

gem 'jbuilder', '~> 1.2'
gem 'state_machine'
# use cancan for user roles
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
  gem 'capybara-select2'
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
gem 'select2-rails', git: 'git@github.com:argerim/select2-rails'
gem 'public_activity', github: 'AnnArborTees/public_activity'
