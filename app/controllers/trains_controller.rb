class TrainsController < ApplicationController
  def create
    @object = fetch_object
    @train_class = params[:train_class].constantize
    @container = params[:container]

    name = @train_class.model_name

    @new_train = @train_class.new

    if @new_train.respond_to?(:created_by_id=)
      @new_train.created_by_id = current_user.id
    end

    if @object.try(name.collection)
      @object.send(name.collection) << @new_train

    elsif @object.respond_to?("#{name.element}=")
      @object.send("#{name.element}=", @new_train)
    else
      raise "#{@object.class.name} appears to not have any relations for #{@train_class}"
    end

    @object.save!

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def show
    @object = fetch_object
    if @object.respond_to?(:full_name)
      @title = @object.full_name
    elsif @object.respond_to?(:name)
      @title = @object.name
    else
      @title = @object.model_name.element.humanize
    end
  end

  def new
    @object = fetch_object
    @type = params[:train_type].to_sym
    @container = params[:container]

    respond_to do |format|
      format.js
    end
  end

  def dangling
    @train_types = []

    params.delete(:filter_type) if params[:filter_type] == 'All'
    @trains = Kaminari.paginate_array(
      Train.all do |trains|
        t = trains.dangling
        @train_types << trains unless t.empty?
        if params[:filter_type]
          next [] unless params[:filter_type] == trains.name
        end
        t
      end
    )
      .page(params[:page])
      .per(40)
  end

  def destroy_dangling
    count = 0
    if params[:destroy_all]
      Train.all do |trains|
        count += trains.dangling.size
        trains.dangling.destroy_all
      end
    else
      ids_for = {}
      params[:dangling_train_ids].each do |train_id|
        class_name, id = train_id.split('#')
        ids_for[class_name] ||= []
        ids_for[class_name] << id
      end

      Train.all do |trains|
        ids = ids_for[trains.name]
        next if ids.blank?

        t = trains.dangling.where(id: ids)
        count += t.size
        t.destroy_all
      end
    end

    flash[:success] = "Successfully destroyed #{count} trains."
    redirect_to dangling_trains_path
  end

  def transition
    @object = fetch_object
    @event  = params[:event].to_sym

    unless @object.train_events.include?(@event)
      @error = "Invalid transition: #{@event} => "\
        "#{@object.send(@object.train_machine.attribute)}"
    end

    unless @object.update_attributes(permitted_attributes)
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
            owner:      public_activity_owner
        )
      end

      record_autocomplete(public_activity_params.reject { |k,_| k == :event })
    end
  end

  def undo
    @object = fetch_object
    if @object.can_undo?
      @object.create_activity(
        action:     :undo,
        parameters: { from: @object.state, to: @object.previous_state },
        owner:      current_user
      )
      @object.update_column :state, @object.previous_state

      begin; Sunspot.index(@object)
      rescue Sunspot::NoSetupError => _; end
    else
      @object.create_activity(
        action:     :undo,
        parameters: { attempt: true },
        owner:      current_user
      )
      @error = "Cannot undo"
    end

    render 'transition'
  end

  def destroy
    respond_to do |format|
      format.html do
        if current_user.role?('admin')
          @object = fetch_object
          if @object.destroy
            redirect_to(order_path(@object.order), notice: 'Successfully destroyed train')
          else
            redirect_to(order_path(@object.order), error: 'Could not destroy the train')
          end
        else
          redirect_to(root_path, notice: "You don't have the proper credentials to destroy a train") unless current_user.role?('admin')
        end
      end
    end
  end

  private

  def record_autocomplete(attrs)
    @object.train_fields_for_event_of_input_type(@event, :text_field).each do |text_field|
      next unless attrs.key?(text_field)

      autocomplete = {
        field: "#{@object.class.name}##{text_field}",
        value: attrs[text_field]
      }
      unless TrainAutocomplete.where(autocomplete).exists?
        TrainAutocomplete.create(autocomplete)
      end
    end
  end

  def fetch_object
    object_class = params[:model_name].camelize.constantize
    object_class.find(params[:id])
  end

  def permitted_attributes
    if params[model_name]
      params_to_permit = @object.train_machine.event_params[@event].try(:keys)
      @object.try(:modify_permitted_params, params_to_permit)

      p = params.permit(model_name => params_to_permit)
    else
      p = { model_name => {} }
    end

    p[model_name]
  end

  def model_name
    @object.model_name.element
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

    if attrs = permitted_attributes
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

  def public_activity_owner
    if params[:public_activity].nil? || params[:public_activity][:owner_id].nil?
      current_user
    else
      User.find params[:public_activity][:owner_id]
    end
  end
end
