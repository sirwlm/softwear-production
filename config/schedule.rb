set :output, {:error => '/home/ubuntu/RailsApps/production.softwearcrm.com/shared/log/cron.error.log',
              :standard => '/home/ubuntu/RailsApps/production.softwearcrm.com/shared/log/cron.log'}

every 3.minutes do
  rake "screens:dry"
end