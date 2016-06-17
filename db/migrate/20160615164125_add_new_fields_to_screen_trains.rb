class AddNewFieldsToScreenTrains < ActiveRecord::Migration
  def up
    add_column :screen_trains, :fba_screen_train_template_id, :integer
    add_column :screen_trains, :separation_difficulty, :integer

    ScreenTrain.unscoped.update_all separation_difficulty: ScreenTrain::DIFFICULTY.key('Normal')
  end

  def down
    remove_column :screen_trains, :fba_screen_train_template_id, :integer
    remove_column :screen_trains, :separation_difficulty, :integer
  end
end
