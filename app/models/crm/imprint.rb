module Crm
  class Imprint < ActiveResource::Base
    include RemoteModel

    self.api_settings_slug = :crm

    belongs_to :order
    belongs_to :job
  end
end
