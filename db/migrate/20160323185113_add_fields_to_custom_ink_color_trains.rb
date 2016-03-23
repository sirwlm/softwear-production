class AddFieldsToCustomInkColorTrains < ActiveRecord::Migration
  def change
    add_column :custom_ink_color_trains, :name, :string
    add_column :custom_ink_color_trains, :notes, :text
  end
end
