class AddJobIdToImprints < ActiveRecord::Migration
  def change
    add_column :imprints, :job_id, :integer
    add_column :jobs, :order_id, :integer
  end
end
