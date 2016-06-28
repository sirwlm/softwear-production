module ImprintData
  extend ActiveSupport::Concern

  included do

    after_initialize :populate_calculated_times

    state_machine :print_data_state, initial: :pending do
      event :confirm_data do
        transition :pending => :confirmed, unless: ->(i) { i.confirmed_setup_time.nil? || i.confirmed_print_time.nil? }
      end

      before_transition on: :confirm_data, do: :populate_calculated_times
      before_transition on: :confirm_data, do: :assign_print_data_adjusted, if: :calculated_and_confirmed_different?
      before_transition on: :confirm_data, do: :assign_confirmed_print_speed
    end

    def assign_print_data_adjusted
      self.update_column(:print_data_adjusted, true)
    end

    def calculated_imprints_per_hour
      ("~%.0f" % ((count * 1.0) / ( self.calculated_print_time * 1.0 ) * 60.0 * 60.0))  rescue "n/a"
    end

    def populate_calculated_times
      self.calculated_setup_time = self.get_metric_value('Setup time') if self.calculated_setup_time.nil?
      self.calculated_print_time = self.get_metric_value('Print time') if self.calculated_print_time.nil?
    end

    private

    def calculated_and_confirmed_different?
      #
      !calculated_print_time.between?(confirmed_print_time - 60, confirmed_print_time + 60) ||
        !calculated_setup_time.between?(confirmed_setup_time - 60, confirmed_print_time + 60)
    end

    def assign_confirmed_print_speed
      self.confirmed_print_speed = ((count * 1.0) / ( self.confirmed_print_time * 1.0 ) * 60.0 * 60.0)
    end
  end

end