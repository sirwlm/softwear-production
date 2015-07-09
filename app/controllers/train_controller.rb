class TrainController < ApplicationController
  def transition
    object_class = params[:model_name].camelize.constantize
    @object = object_class.find(params[:id])
    @event  = params[:event].to_sym

    @object.train_machine.events.fetch(@event).fire(@object)
    @object.create_activity(
      action:     :transition,
      parameters: public_activity_params,
      owner:      current_user
    )
    @object.save!

    # TODO make js response
    render inline: ''
  end

  private

  def public_activity_params
    p = {}
    p[:event] = @event
    if params[:public_activity]
      if extra = @object.train_machine.event_public_activity[@event.to_sym]
        extra.each do |key, type|
          p[key] = params[:public_activity][key]
        end
      end
    end
    p
  end
end
