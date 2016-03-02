module Crm
  class Shipment < ActiveResource::Base
    include RemoteModel
    self.api_settings_slug = :crm
  end
end
