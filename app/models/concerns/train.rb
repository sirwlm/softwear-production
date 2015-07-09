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

  included do
    def self.state_machine(*args, &block)
      StateMachines::Machine.find_or_create(self, *args)
    end
  end
end
