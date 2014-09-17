class CreateTrains < ActiveRecord::Migration
  def change
    create_table :trains do |t|
      t.string :kind
      t.integer :trainable_id
      t.string :trainable_type
      t.timestamps
    end
  end
end
