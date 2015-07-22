class CreateFbaLabelTrains < ActiveRecord::Migration
  def change
    create_table :fba_label_trains do |t|
      t.string :state
      t.integer :order_id
      t.timestamps null: false
    end
  end
end
