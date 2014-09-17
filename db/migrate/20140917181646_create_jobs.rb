class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :softwear_crm_id
      t.references :order
      t.timestamps
    end
  end
end
