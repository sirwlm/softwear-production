module Crm
  class Job < ActiveResource::Base
    include RemoteModel
    
    self.api_settings_slug = :crm
    # add_response_method :http_response

    has_many :imprints
  end
end