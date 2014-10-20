module Crm
  class Imprint < ActiveResource::Base
    include RemoteModel
    
    self.api_settings_slug = :crm
    # add_response_method :http_response
  end
end