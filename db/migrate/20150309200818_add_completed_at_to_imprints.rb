class AddCompletedAtToImprints < ActiveRecord::Migration
  def change
    add_column :imprints, :completed_at, :timestamp
    add_column :imprints, :completed_by_id, :integer
  end
end
