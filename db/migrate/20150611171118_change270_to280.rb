class Change270To280 < ActiveRecord::Migration
  def up
    Screen.where(mesh_type: "270").update_all(mesh_type: "280")
  end

  def down
    Screen.where(mesh_type: "280").update_all(mesh_type: "270")
  end
end
