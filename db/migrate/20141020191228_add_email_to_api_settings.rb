class AddEmailToApiSettings < ActiveRecord::Migration
  def change
    add_column :api_settings, :auth_email, :string
  end
end
