class AddRevolvedBooleanToImprints < ActiveRecord::Migration
  def change
    add_column :imprints, :revolved, :boolean
  end
end
