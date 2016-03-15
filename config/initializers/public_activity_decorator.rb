module PublicActivity
  class Activity
    include Softwear::Auth::BelongsToUser

    belongs_to_user_called :owner

    def owner=(o)
      if o.nil?
        @owner = nil
        return
      end

      self.owner_type = o.class.name
      if o.is_a?(User)
        super
      else
        self.owner_id = o.id
      end
      @owner = o
    end

    def owner
      return nil if owner_type.blank? || owner_id.blank?
      @owner ||= self.owner_type.constantize.find(owner_id)
    end
  end

  module Renderable
    alias_method :super_render, :render
    def render(context, params={})
      begin
        super_render(context, params.dup)
      rescue ActionView::MissingTemplate => e
        # If there was no view for the particular model, we look
        # for default instead.
        key_for_default = self.key.split('.')
        key_for_default[-2] = 'default'
        path = key_for_default.join '/'
        super_render(context, params.merge(partial: path)) rescue raise e
      end
    end
  end
end
