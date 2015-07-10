# -- State Machine Example Usage --
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

  module StateMachine
    attr_accessor :event_categories
    attr_accessor :event_params
    attr_accessor :event_public_activity

    # -- So that:
    # ``` failure_event :mess_it_up ```
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
  end

  included do
    cattr_accessor :train_machine

    def self.train(*args, &block)
      if train_machine && train_machine.attribute != args.first
        raise "Only one train can be defined per object"
      end

      self.train_machine = StateMachines::Machine.find_or_create(self, *args)
      train_machine.instance_eval { extend Train::StateMachine }
      train_machine.instance_eval(&block)

      class_eval <<-RUBY, __FILE__, __LINE__
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
      RUBY
    end
  end

  def train_machine
    self.class.train_machine
  end
end
