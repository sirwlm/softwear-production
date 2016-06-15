###################
# The following methods are used in the transition action, and should be overriden in including classes:
# (* = required, - = optional)
#
# * fetch_object           -> train record from params
# * object_param           -> parameter name (i.e. "imprint") to get transition params from
# - public_activity_owner  -> public activity owner to assign
# - record_autocomplete    -> to record transition parameter choices
#
###################
module TransitionAction
  extend ActiveSupport::Concern

  def transition
    @object = fetch_object
    @event  = params[:event].to_sym

    unless @object.train_events.include?(@event)
      @error = "Invalid transition: #{@event} => "\
        "#{@object.send(@object.train_machine.attribute)}"
    end

    unless @object.update_attributes(train_event_attributes)
      @error = @object.errors.full_messages.join(', ')
    end

    if @error
      @object.try(
          :issue_warning, 'State Transition',
          "Error transitioning states: #{@error}"
      )
    else
      target = @object.try(:event_target) || @object

      unless @object.train_machine.events.fetch(@event).fire(target)
        @errors = @object.errors.full_messages
      end

      if @object.respond_to?(:create_activity)
        @object.create_activity(
            action:     :transition,
            parameters: public_activity_params(@errors),
            owner:      respond_to?(:public_activity_owner, true) ? public_activity_owner : nil
        )
      end

      if respond_to?(:record_autocomplete, true)
        record_autocomplete(public_activity_params.reject { |k,_| k == :event })
      end
    end
  end

  protected
  
  def train_event_attributes
    if params[object_param]
      params_to_permit = @object.train_machine.event_params[@event].try(:keys)
      @object.try(:modify_permitted_params, params_to_permit)

      p = params.permit(object_param => params_to_permit)
    else
      p = { object_param => {} }
    end

    p[object_param]
  end

  def public_activity_params(errors = nil)
    return @public_activity_params unless @public_activity_params.nil?

    @public_activity_params = {}
    @public_activity_params[:event] = @event.to_s

    if params[:public_activity]
      if extra = @object.train_machine.event_public_activity[@event.to_sym]
        extra.each do |key, type|
          val = params[:public_activity][key]
          @public_activity_params[key] = val if val
        end
      end
    end

    if attrs = train_event_attributes
      attrs.each do |key, type|
        next if @object.class.train_public_activity_blacklist.try(:include?, key.to_sym)

        val = attrs[key]
        @public_activity_params[key.to_sym] = val if val
      end
    end

    if !errors.blank?
      @public_activity_params[:errors] = errors.join(', ')
    end

    @public_activity_params
  end
end