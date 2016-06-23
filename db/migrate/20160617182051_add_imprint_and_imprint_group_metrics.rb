class AddImprintAndImprintGroupMetrics < ActiveRecord::Migration
  def change
    add_column :imprints, :print_data_state, :string
    add_column :imprints, :print_data_adjusted, :boolean
    add_column :imprints, :calculated_print_time, :integer
    add_column :imprints, :confirmed_print_time, :integer
    add_column :imprints, :calculated_setup_time, :integer
    add_column :imprints, :confirmed_setup_time, :integer
    add_column :imprints, :confirmed_print_speed, :decimal, precision: 10, scale: 2

    Imprint.update_all print_data_state: :pending

    add_column :imprint_groups, :print_data_state, :string
    add_column :imprint_groups, :print_data_adjusted, :boolean
    add_column :imprint_groups, :calculated_print_time, :integer
    add_column :imprint_groups, :confirmed_print_time, :integer
    add_column :imprint_groups, :calculated_setup_time, :integer
    add_column :imprint_groups, :confirmed_setup_time, :integer
    add_column :imprint_groups, :confirmed_print_speed, :decimal, precision: 10, scale: 2

    ImprintGroup.update_all print_data_state: :pending

  end
end
