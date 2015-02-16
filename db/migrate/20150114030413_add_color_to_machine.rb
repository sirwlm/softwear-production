class AddColorToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :color, :string
  end
end
