class CreateApiSettings < ActiveRecord::Migration
  def change
    create_table :api_settings do |t|
      t.string :endpoint
      t.string :auth_token
      t.string :homepage
      t.string :slug

      t.timestamps
    end
    add_index :api_settings, :slug, unique: true
  end
end
