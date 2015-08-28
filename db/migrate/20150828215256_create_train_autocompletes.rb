class CreateTrainAutocompletes < ActiveRecord::Migration
  def change
    create_table :train_autocompletes do |t|
      t.string :field
      t.string :value

      t.timestamps null: false
    end

    add_index :train_autocompletes, :field
  end
end
