class RemovePrimaryFromScreenRequests < ActiveRecord::Migration
  def change
    remove_column :screen_requests, :primary, :boolean
  end
end
