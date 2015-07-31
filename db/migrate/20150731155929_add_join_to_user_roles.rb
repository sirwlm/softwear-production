class AddJoinToUserRoles < ActiveRecord::Migration
  def change
    add_column :user_roles, :user_id, :integer
    add_column :user_roles, :role_id, :integer
  end
end
