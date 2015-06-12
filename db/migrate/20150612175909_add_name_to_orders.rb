class AddNameToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :name, :string
    add_column :jobs, :name, :string
  end
end
