require 'sidekiq'
require 'sidekiq-status'

redis_url = "#{Figaro.env.redis_path}/#{Figaro.env.redis_db || 4}"

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
  config.redis = { namespace: 'softwear-production', url: redis_url, network_timeout: 10 }
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
  end
  config.redis = { namespace: 'softwear-production', url: redis_url }
end

SafeYAML::OPTIONS[:default_mode] = :unsafe
