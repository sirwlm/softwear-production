set :output, {:error => '/home/ubuntu/RailsApps/production.softwearcrm.com/shared/log/cron.error.log',
              :standard => '/home/ubuntu/RailsApps/production.softwearcrm.com/shared/log/cron.log'}

job_type :rake, "{ cd #{@current_path} > /dev/null; } && RAILS_ENV=:environment /home/ubuntu/.rvm/wrappers/ruby-2.1.1/bundle exec rake :task --silent :output"

every 1.minute do
  rake "screens:dry"
end
