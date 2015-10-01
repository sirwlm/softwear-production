class ChangeImprintableTrainFinalStateToInventoried < ActiveRecord::Migration
  def change
    ImprintableTrain
      .unscoped
      .where(state: 'staged')
      .update_all(state: 'inventoried')
  end
end
