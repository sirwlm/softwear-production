set :output, {:error => '/home/ubuntu/RailsApps/production.softwearcrm.com/shared/log/cron.error.log',
              :standard => '/home/ubuntu/RailsApps/production.softwearcrm.com/shared/log/cron.log'}

job_type :rake, "{ cd #{@current_path || ':path'} > /dev/null; } && RAILS_ENV=:environment rvm 2.1.1 do bundle exec rake :task --silent :output"

every 1.minute do
  rake "screens:dry"
end
