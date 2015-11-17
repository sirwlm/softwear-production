class MoveLpiOverToScreenTrains < ActiveRecord::Migration
  def change
    add_column :screen_trains, :lpi, :string
    remove_column :screen_requests, :lpi, :string
  end
end
