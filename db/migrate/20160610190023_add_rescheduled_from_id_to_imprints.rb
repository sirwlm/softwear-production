class AddRescheduledFromIdToImprints < ActiveRecord::Migration
  def change
    add_column :imprints, :rescheduled_from_id, :integer
    add_column :imprint_groups, :rescheduled_from_id, :integer
  end
end
