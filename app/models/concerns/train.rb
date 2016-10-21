# -- Modified State Machine Example Usage --
=begin

# To have an attribute assigned:
success_event :printing_complete, params: { completed_by_id: User.all } do
  transition :in_production => :numbers_confirmed
end

# To have a public activity parameter assigned:
failure_event :bad_prep, public_activity: { reason: SCREEN_BAD_PREP_REASONS } do
  transition [:reclaimed_and_drying, :ready_to_coat, :coated_and_drying, :ready_to_expose, :washed_out_and_drying, :ready_to_tape, :in_production] => :ready_to_reclaim
end

=end

module Train
  extend ActiveSupport::Concern
  include TrainSearch

  def self.train_types
    Thread.main[:train_types] ||= {}
  end

  def self.train_types=(value)
    Thread.main[:train_types] = value
  end

  def self.all(&block)
    train_classes = train_types.flat_map(&:last)
    if block_given?
      train_classes.flat_map(&block)
    else
      train_classes.flat_map(&:all)
    end
  end

  def self.type_of(train_class)
    train_types.each do |type, classes|
      return type if classes.include?(train_class)
    end
    nil
  end

  def self.available_trains_of_type(type, record)
    return [] unless Train.train_types.key?(type)

    Train.train_types[type].select do |train_class|
      record.class.reflect_on_all_associations.any? do |assoc|
        next false unless train_class == assoc.klass || assoc.klass.descendants.include?(train_class)
        next false if !assoc.collection? && !record.send(assoc.name).nil?
        true
      end
    end
  end

  def self.each_train(record, &block)
    already_sent_assocs = {}

    Train.train_types.values.flatten.each do |train_class|
      record.class.reflect_on_all_associations.each do |assoc|
        next unless train_class == assoc.klass || assoc.klass.descendants.include?(train_class)

        result = record.send(assoc.name)
        next if result.blank?

        next if already_sent_assocs[assoc.name]
        already_sent_assocs[assoc.name] = true

        if assoc.collection?
          result.each(&block)
        else
          yield result
        end
      end
    end
  end

  def self.each_train_of_type(type, record, &block)
    return unless Train.train_types.key?(type)

    already_sent_assocs = {}

    Train.train_types[type].each do |train_class|
      record.class.reflect_on_all_associations.each do |assoc|
        next unless train_class == assoc.klass || assoc.klass.descendants.include?(train_class)

        result = record.send(assoc.name)
        next if result.blank?

        next if already_sent_assocs[assoc.name]
        already_sent_assocs[assoc.name] = true

        if assoc.collection?
          result.each(&block)
        else
          yield result
        end
      end
    end
  end

  module StateMachine
    attr_accessor :event_categories
    attr_accessor :event_params
    attr_accessor :event_public_activity
    attr_accessor :complete_state
    attr_accessor :first_state
    attr_accessor :state_types

    # -- So that:
    # failure_event :mess_it_up
    # -- Will add :mess_it_up to event_categories[:failure]
    def method_missing(name, *args, &block)
      if /(?<category>\w+)_event/ =~ name.to_s
        self.event_categories ||= {}
        event_categories[category.to_sym] ||= []
        event_categories[category.to_sym] += args.reject { |a| a.is_a?(Hash) }.map(&:to_sym)

        event(*args, &block)
      elsif owner_class.respond_to?(name)
        owner_class.send(name, *args, &block)
      else
        super
      end
    end

    # -- Allow passing params: or public_activity: to `event` calls
    def event(*names, &block)
      if names.last.is_a?(Hash)
        set_option = lambda do |hash, value|
          names.each do |name|
            next if name.is_a?(Hash)
            hash[name.to_sym] = value
          end
        end

        if params = names.last.delete(:params)
          self.event_params ||= {}
          set_option[event_params, params]
        end
        if public_activity = names.last.delete(:public_activity)
          self.event_public_activity ||= {}
          set_option[event_public_activity, public_activity]
        end
      end

      super
    end

    def state(name, *args)
      options = args.last
      return super unless options.try(:key?, :type)

      self.state_types ||= {}
      self.state_types[name.to_sym] = options.delete(:type)
      super
    end
  end

  included do
    cattr_accessor :train_machine
    cattr_accessor :train_public_activity_blacklist
    try :after_save, :touch_order
    try :after_validation, :update_previous_state, if: :state_changed?
    try :after_destroy, :update_order_production_status

    try :scope, :dangling, -> { where dependent_field => nil }
    try :scope, :with_bad_state, -> { where.not train_machine.attribute => train_machine.states.map(&:name) }

    def self.dependent_field
      column_names.include?('job_id') ? :job_id : :order_id
    end

    def self.train_type(type)
      key = type.to_sym
      if Train.train_types.key?(key)
        Train.train_types[key].delete_if { |t| t.name == name }
        Train.train_types[key] << self

      else
        Train.train_types[key] = []

        Train.instance_eval <<-RUBY, __FILE__, __LINE__
          def self.#{key}_trains
            Train.train_types[:#{key}]
          end
        RUBY

        Train.train_types[key] << self
      end
      (Train.train_types[key] ||= []).tap do |t|
        t << self unless t.include?(self)
      end
    end

    def self.default_train_events
      proc do
        failure_event :cancel do
          transition (any - :canceled) => :canceled
        end

        state :canceled, type: :failure
      end
    end

    def self.train(*args, &block)
      final_state = args.last.try(:delete, :final)
      initial_state = args.last.try(:[], :initial)

      self.train_machine = StateMachines::Machine.find_or_create(self, *args)
      unless train_machine.singleton_class.included_modules.include?(Train::StateMachine)
        train_machine.instance_eval { extend Train::StateMachine }
      end
      train_machine.instance_eval(&block)
      train_machine.instance_eval(&default_train_events) if default_train_events
      train_machine.complete_state = final_state.to_sym if final_state
      train_machine.first_state = initial_state.to_sym if initial_state

      train_machine.after_transition(
        train_machine.send(:any) => train_machine.complete_state,
        do: :update_order_completion_status
      )

      train_machine.after_transition(
        train_machine.send(:any) => train_machine.complete_state,
        do: :try_on_complete
      )

      if respond_to?(:searchable)
        searchable do
          string :train_type
          boolean(:canceled) { canceled? }
        end
      end

      class_eval <<-RUBY, __FILE__, __LINE__
        def #{train_machine.attribute}_events(*args)
          train_events(*args)
        end

        def #{train_machine.attribute}_type
          complete? ? :complete : train_state_type(#{train_machine.attribute})
        end
      RUBY
    end

    def self.dont_track(*fields)
      self.train_public_activity_blacklist ||= []
      self.train_public_activity_blacklist += fields
    end
  end

  def train_events(*args)
    if args.first.is_a?(Symbol)
      category = args.first
      options  = args.last.is_a?(Hash) ? args.last : {}

      if train_machine.event_categories[category].nil?
        raise "No event category :"+category.to_s+" exists"
      end

      train_machine.events.valid_for(self, options).map(&:name).select do |event|
        train_machine.event_categories[category.to_sym].include?(event.to_sym)
      end
    else
      train_machine.events.valid_for(self, *args).map(&:name)
    end
  end

  def order_earliest_scheduled_at
    order.imprints.minimum(:scheduled_at) rescue nil
  end

  def order_earliest_scheduled_at_date
    order_earliest_scheduled_at.strftime("%Y-%m-%d") rescue nil
  end

  def train_machine
    self.class.train_machine
  end

  def train_type
    Train.type_of(self.class)
  end

  def train_class
    self.class.name.underscore
  end

  def first_state
    train_machine.first_state
  end

  def complete_state
    train_machine.complete_state
  end

  def at_initial_state
    state.to_s == first_state.to_s
  end
  def at_initial_state=(_value)
    # NOTE because we send #at_initial_state over via trains_controller, ActiveResource
    # on CRM's end will send back that value when saving records. This catches that
    # and does nothing.
  end

  def complete?
    send(train_machine.attribute).to_sym == train_machine.complete_state
  end

  # This happens after_transition any => complete
  def update_order_completion_status
    return if try(:order).nil?
    return unless order.respond_to?(:delay)
    Order.delay.update_crm_production_status(order.id) if order.complete?

  rescue StandardError => _
  end

  def usual_fields
    [train_machine.attribute] +
    [:id, :created_at, :updated_at, :scheduled_at, :estimated_time, :estimated_end_at] +
    self.class.reflect_on_all_associations
      .select { |a| a.is_a?(ActiveRecord::Reflection::BelongsToReflection) }
      .map { |a| a.foreign_key.to_sym }
  end

  def details
    deets = {}
    (self.class.column_names.map(&:to_sym) - usual_fields).each do |field|
      deets[field] = try(field)
    end
    deets
  end

  def serializable_hash(options = {})
    super(
      {
        only: usual_fields,
        methods: [:train_type, :train_class, :state_type, :details],
      }
        .merge(options)
    )
  end

  def train_state_type(state)
    return nil if train_machine.state_types.nil?
    train_machine.state_types[state]
  end

  def train_fields_for_event_of_input_type(event, input_type)
    fields = []

    (train_machine.event_public_activity.try(:[], event.to_sym) || {})
    .merge(train_machine.event_params.try(:[], event.to_sym) || {})
      .each do |field, type|
        fields << field if type == input_type
      end

    fields
  end

  def display
    begin
      super
    rescue Exception => e
      try(:name) || 'Unknown train'
    end
  end

  def display_order_deadline
    if try(:order).try(:deadline).respond_to?(:strftime)
      order.deadline.strftime("%a, %b %d, %Y")
    else
      'None'
    end
  end

  def display_order_name
    try(:order).try(:name) || 'No order'
  end

  def fba
    try(:order).try(:fba?)
  end
  alias_method :fba?, :fba

  def update_order_completion_status
    return if try(:order).nil?

    if Rails.env.production?
      Order.delay.update_crm_production_status(order.id)
    else
      order.update_crm_production_status!
    end
  end

  def touch_order
    return if try(:order).nil?

    # Weird but intentional - properly reindexes order in Sunspot.
    order.reload.save
  end

  def touch_job
    return if try(:job).nil?

    # Weird but intentional - properly reindexes job in Sunspot.
    job.reload.save
  end

  def force_complete(skip_callbacks = true)
    update = method(skip_callbacks ? :update_column : :update_attribute)
    update[:state, train_machine.complete_state]
    update_column :completed_at, Time.now if is_a?(Schedulable)

    # Never skip sunspot! (but do skip callbacks)
    begin; Sunspot.index(self)
    rescue Sunspot::NoSetupError => _; end
  end

  def update_previous_state
    try(:previous_state=, state_was)
  end

  def can_undo?
    respond_to?(:previous_state) && !previous_state.nil? && previous_state != state
  end

  def train_id
    "#{self.class.name}##{id}"
  end

  def try_on_complete
    on_complete if respond_to?(:on_complete)
  end

  def canceled
    canceled?
  end
end
