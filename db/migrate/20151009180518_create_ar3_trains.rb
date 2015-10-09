class CreateAr3Trains < ActiveRecord::Migration
  def change
    create_table :ar3_trains do |t|
      t.string :state
      t.integer :order_id
      t.string :artwork_location
      t.text :notes

      t.timestamps null: false
    end
  end
end
