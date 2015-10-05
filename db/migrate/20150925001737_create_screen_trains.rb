class CreateScreenTrains < ActiveRecord::Migration
  def change
    create_table :screen_trains do |t|
      t.string :state, index: true
      t.integer :order_id, index: true
      t.decimal :separation_time, precision: 10, scale: 2, index: true
      t.boolean :new_separation, index: true
      t.datetime :due_at, index: true
      t.integer :signed_off_by_id, index: true
      t.integer :assigned_to_id, index: true
      t.text :notes
      t.string :garment_material, index: true
      t.string :garment_weight, index: true
      t.string :artwork_location, index: true
      t.string :print_type, index: true
      t.timestamps null: false
    end

    add_column :imprints, :screen_train_id, :integer, index: :true
  end
end
