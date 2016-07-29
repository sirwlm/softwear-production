class AddScreenCountToImprints < ActiveRecord::Migration
  def up
    add_column :imprints, :screen_count, :integer
    Imprint.find_each { |i| i.update_column :screen_count, i.screen_requests.count }
  end

  def down
    remove_column :imprints, :screen_count, :integer
  end
end
