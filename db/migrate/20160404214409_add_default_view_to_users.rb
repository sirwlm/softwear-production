class AddDefaultViewToUsers < ActiveRecord::Migration
  def change
    add_column :users, :default_view, :string
  end
end
