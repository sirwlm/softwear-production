module Crm
  class ArtworkRequest < ActiveResource::Base
    include RemoteModel

    self.api_settings_slug = :crm

    has_many :imprints
    belongs_to :job
  end
end
