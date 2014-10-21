module Crm
  class Order < ActiveResource::Base
    include RemoteModel
    
    self.api_settings_slug = :crm
    # add_response_method :http_response

    has_many :jobs
  end
end