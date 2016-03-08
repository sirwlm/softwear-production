class DropRoles < ActiveRecord::Migration
  def change
    drop_table :roles
    drop_table :user_roles
  end
end
