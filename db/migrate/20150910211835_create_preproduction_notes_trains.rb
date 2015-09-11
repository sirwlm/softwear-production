class CreatePreproductionNotesTrains < ActiveRecord::Migration
  def change
    create_table :preproduction_notes_trains do |t|
      t.text :decoration_placement
      t.text :print_order
      t.text :special_instructions
      t.integer :job_id
      t.string :state

      t.timestamps null: false
    end
  end
end
