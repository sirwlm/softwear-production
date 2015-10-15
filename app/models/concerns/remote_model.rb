module RemoteModel
  extend ActiveSupport::Concern

  included do
    class << self
      attr_accessor :api_settings_slug

      def api_settings_slug=(slug)
        @api_settings_slug = slug
        
        define_singleton_method :api_settings do
          @api_settings ||= ApiSetting.find_by(slug: slug.to_s)
        end

        begin
          self.site = api_settings.try(:endpoint) || "http://invalid-#{slug}.com/api"
        rescue ActiveRecord::StatementInvalid => e
          puts "WARNING: *********************************************"
          puts e.message
          puts "******************************************************"
          self.site = "http://invalid-#{slug}.com/api"
        end
      end

      unless Rails.env.test?
        def headers
          if api_settings.nil?
            raise(
              "Please assign api_settings_slug in the model #{name} " +
              "or add an api setting with slug #{@api_settings_slug}."
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
end
