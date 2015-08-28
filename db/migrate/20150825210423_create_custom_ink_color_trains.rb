class CreateCustomInkColorTrains < ActiveRecord::Migration
  def change
    create_table :custom_ink_color_trains do |t|
      t.string :state
      t.integer :job_id
      t.string :pantone_color
      t.string :volume

      t.timestamps null: false
    end
  end
end
