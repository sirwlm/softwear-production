class AddFieldsToImprintableTrains < ActiveRecord::Migration
  def change
    add_column :imprintable_trains, :location, :string
    add_column :imprintable_trains, :expected_arrival_date, :datetime
  end
end
