class AddDeadlineToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :deadline, :datetime
  end
end
