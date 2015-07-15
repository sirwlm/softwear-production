module CalendarEventController
  extend ActiveSupport::Concern

  included do
    before_filter :move_event_to_table_name_in_params
  end

  def update
    update! do |format|
      format.json do
        if params[:return_content]
          partial = 'machines/unscheduled_entry'
        else
          partial = 'machines/calendar_entry'
        end
        render partial: partial, locals: {
          event: instance_variable_get('@' + resource_class.table_name.singularize)
        }
      end
    end
  end

  protected

  def calendar_event_params(*others)
    ([:estimated_time, :scheduled_at, :machine_id, :completed_at] + others).uniq
  end

  def move_event_to_table_name_in_params
    if params[:event]
      params[resource_class.table_name.singularize] = params[:event]
    end
  end
end
