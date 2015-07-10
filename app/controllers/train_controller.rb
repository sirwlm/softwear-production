class TrainController < ApplicationController
  def transition
    object_class = params[:model_name].camelize.constantize
    @object = object_class.find(params[:id])
    @event  = params[:event].to_sym

    unless @object.train_events.include?(@event)
      @error = "Invalid transition: #{@event} => "\
        "#{@object.send(@object.train_machine.attribute)}"
    end

    @object.train_machine.events.fetch(@event).fire(@object)
    if @object.respond_to?(:create_activity)
      @object.create_activity(
        action:     :transition,
        parameters: public_activity_params,
        owner:      current_user
      )
    end
    unless @object.update_attributes(permitted_attributes)
      @error = @object.errors.full_messages.join(', ')
    end
  end

  private

  def permitted_attributes
    p = if params[model_name]
          params.permit(model_name =>
            @object.train_machine.event_params[@event].try(:keys)
          )
        else
          { model_name => {} }
        end
    p[model_name]
  end

  def model_name
    @object.model_name.element
  end

  def public_activity_params
    p = {}
    p[:event] = @event
    if params[:public_activity]
      if extra = @object.train_machine.event_public_activity[@event.to_sym]
        extra.each do |key, type|
          val = params[:public_activity][key]
          p[key] = val if val
        end
      end
    end
    p
  end
end
