class CreateApiSettings < ActiveRecord::Migration
  def change
    create_table :api_settings do |t|
      t.string :endpoint
      t.string :site_name
      t.string :auth_token
      t.string :homepage
    end
  end
end
