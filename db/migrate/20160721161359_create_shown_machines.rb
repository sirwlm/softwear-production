class CreateShownMachines < ActiveRecord::Migration
  def change
    create_table :shown_machines do |t|
      t.integer :user_id
      t.integer :machine_id
    end
    add_index :shown_machines, :user_id
    add_index :shown_machines, :machine_id
  end
end
