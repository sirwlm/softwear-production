class AddStartedAtToImprints < ActiveRecord::Migration
  def change
    add_column :imprints, :started_at, :datetime
    add_column :imprint_groups, :started_at, :datetime
  end
end
