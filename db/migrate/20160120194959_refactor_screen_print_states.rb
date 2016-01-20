class RefactorScreenPrintStates < ActiveRecord::Migration
  def change
    ScreenPrint.where(state: 'pending_preproduction').update_all(state: :pending_setup)
    ScreenPrint.where(state: 'ready_to_print').update_all(state: :pending_setup)
  end
end
