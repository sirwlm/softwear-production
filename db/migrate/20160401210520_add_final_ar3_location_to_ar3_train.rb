class AddFinalAr3LocationToAr3Train < ActiveRecord::Migration
  def change
    add_column :ar3_trains, :final_ar3_location, :string
  end
end
