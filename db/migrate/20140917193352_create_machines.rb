class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :name
      t.timestamps
    end

    add_reference :imprints, :machine
    add_index :imprints, :machine_id
  end
end
