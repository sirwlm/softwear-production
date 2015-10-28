class AddCustomerNameToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :customer_name, :string, index: true
  end
end
