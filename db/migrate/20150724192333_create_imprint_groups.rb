class CreateImprintGroups < ActiveRecord::Migration
  def change
    create_table :imprint_groups do |t|
      t.integer :order_id

      t.datetime :scheduled_at
      t.datetime :estimated_end_at
      t.decimal  :estimated_time
      t.integer  :machine_id
      t.datetime :completed_at
      t.integer  :completed_by_id
      t.boolean  :require_manager_signoff
      t.string   :type

      t.timestamps null: false
    end

    add_column :orders, :has_imprint_groups, :boolean
    add_column :imprints, :imprint_group_id, :integer
  end
end
