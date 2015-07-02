DRY_EVERY = 1.minute

unless defined?(Rails::Console) or Rails.env.development? or Rails.env.test?
  Thread.new do
    require "#{Rails.root}/app/models/screen"

    loop do
      begin
        Screen.dry_screens
        ActiveRecord::Base.clear_active_connections!
        sleep 1.minute
      rescue Exception => e
        Rails.logger.error "URGENT: #{e} was thrown during pull loop. Trying again in 1 minute."
        e.backtrace.each(&Rails.logger.method(:error))
        ActiveRecord::Base.clear_active_connections!
        sleep 1.minute
        Rails.logger.error "1 hour has passed, trying again..."
      end
    end
  end
end


