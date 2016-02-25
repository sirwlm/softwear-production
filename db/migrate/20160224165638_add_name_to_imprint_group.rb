class AddNameToImprintGroup < ActiveRecord::Migration
  def change
    add_column :imprint_groups, :name, :string
  end
end
