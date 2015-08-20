module Crm
  class Order < ActiveResource::Base
    include RemoteModel

    self.api_settings_slug = :crm

    # has_many :jobs
    # has_many :proofs
  end
end
