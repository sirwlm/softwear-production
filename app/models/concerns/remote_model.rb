module RemoteModel
  extend ActiveSupport::Concern

  included do
    class << self
      def api_settings_slug=(slug)
        def self.api_settings
          @api_settings ||= ApiSettings.find_by(slug: slug)
        end
      end

      def self.headers
        if api_settings.nil?
          raise(
            "Please assign api_settings_slug in the model #{self.class.name}"
          )
        end

        prefix = api_settings.slug.camelize
        (super or {}).merge(
          "#{prefix}-User-Token" => api_settings.auth_token,
          "#{prefix}-User-Email" => api_settings.auth_email
        )
      end
    end
  end
end