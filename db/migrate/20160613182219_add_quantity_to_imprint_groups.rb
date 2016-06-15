class AddQuantityToImprintGroups < ActiveRecord::Migration
  def change
    add_column :imprint_groups, :quantity, :integer
  end
end
