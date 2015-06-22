class AddStateToImprints < ActiveRecord::Migration
  def up
    add_column :imprints, :state, :string
    Imprint.unscoped
      .where(approved: true, scheduled_at: nil, completed_at: nil).update_all(state: :pending_scheduling)
    Imprint.unscoped
      .where(approved: true)
      .where(completed_at: nil)
      .where.not(scheduled_at: nil).update_all(state: :ready_to_print)
    Imprint.unscoped
      .where.not(completed_at: nil).update_all(state: :complete)
    remove_column :imprints, :approved
  end

  def down
    add_column :imprints, :approved, :boolean
    Imprint.unscoped.where.not(state: :pending_approval).update_all(approved: true)
    remove_column :imprints, :state
  end
end
