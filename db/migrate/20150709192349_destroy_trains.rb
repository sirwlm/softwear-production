class DestroyTrains < ActiveRecord::Migration
  def change
    drop_table :trains
  end
end
