class ChangeScreenStateOfTapedToInProduction < ActiveRecord::Migration
  def change
    Screen.where(state: "ready_to_tape").update_all(state: "in_production") 
  end
end
