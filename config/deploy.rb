require 'softwear/lib/capistrano'
lock '3.2.1'

set :application, 'softwear-production'
set :repo_url, 'git@github.com:annarbortees/softwear-production.git'
set :rvm_ruby_version, 'rbx-2.5.2'
set :rvm_ruby_string, 'rbx-2.5.2'
set :rvm_task_ruby_version, 'ruby-2.1.2'
set :no_reindex, true

# Default branch is :master
ask :branch, 'master'


# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/ubuntu/RailsApps/production.softwearcrm.com'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/application.yml config/sunspot.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 10

Softwear::Lib.capistrano(self)
