class CreateImprints < ActiveRecord::Migration
  def change
    create_table :imprints do |t|
      t.integer :softwear_crm_id
      t.references :job
      t.timestamp :scheduled_at
      t.decimal :estimated_time, precision: 10, scale: 2
      t.timestamps
    end
  end
end
