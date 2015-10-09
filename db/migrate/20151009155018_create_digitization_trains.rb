class CreateDigitizationTrains < ActiveRecord::Migration
  def change
    create_table :digitization_trains do |t|
      t.string :state
      t.string :artwork_location
      t.string :third_party_name
      t.integer :digitization_assigned_to_id
      t.integer :approved_by_id
      t.integer :order_id
      t.string :third_party_name
      t.text :notes

      t.timestamps null: false
    end
  end
end
