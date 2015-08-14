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

  def self.train_types
    Thread.main[:train_types] ||= {}
  end
  def self.train_types=(value)
    Thread.main[:train_types] = value
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
      name = train_class.model_name
      if record.try(name.collection)
        true
      elsif record.respond_to?(name.element) && record.send(name.element).nil?
        true
      else
        false
      end
    end
  end

  def self.each_train_of_type(type, record, &block)
    return unless Train.train_types.key?(type)

    Train.train_types[type].each do |train_class|
      name = train_class.model_name

      if record.try(name.collection)
        record.send(name.collection).each(&block)
      end

      if record.respond_to?(name.element) && !record.send(name.element).nil?
        yield record.send(name.element)
      end
    end
  end

  module StateMachine
    attr_accessor :event_categories
    attr_accessor :event_params
    attr_accessor :event_public_activity
    attr_accessor :complete_state
    attr_accessor :state_types

    # -- So that:
    # failure_event :mess_it_up
    # -- Will add :mess_it_up to the :failure events
    def method_missing(name, *args, &block)
      if /(?<category>\w+)_event/ =~ name.to_s
        self.event_categories ||= {}
        event_categories[category.to_sym] ||= []
        event_categories[category.to_sym] += args.reject { |a| a.is_a?(Hash) }.map(&:to_sym)

        event(*args, &block)
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
    end
  end

  included do
    cattr_accessor :train_machine

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

    def self.train(*args, &block)
      if train_machine && train_machine.attribute != args.first
        raise "Only one train can be defined per object"
      end

      final_state = args.last.try(:delete, :final)

      self.train_machine = StateMachines::Machine.find_or_create(self, *args)
      train_machine.instance_eval { extend Train::StateMachine }
      train_machine.instance_eval(&block)
      train_machine.complete_state = final_state.to_sym if final_state

      class_eval <<-RUBY, __FILE__, __LINE__
        searchable do
          string :train_type
        end

        def #{train_machine.attribute}_events(*args)
          train_machine = self.class.train_machine

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

        def train_events(*args)
          #{train_machine.attribute}_events(*args)
        end

        def #{train_machine.attribute}_type
          complete? ? :complete : train_state_type(#{train_machine.attribute})
        end
      RUBY
    end
  end

  def train_machine
    self.class.train_machine
  end

  def train_type
    Train.type_of(self.class)
  end

  def train_name
    self.class.name.underscore.humanize
  end

  def complete?
    send(train_machine.attribute).to_sym == train_machine.complete_state
  end

  def serializable_hash(options = {})
    super(
      { methods: [:train_type, :train_name, :state_type] }.merge(options)
    )
  end

  def train_state_type(state)
    train_machine.state_types[state]
  end
end
