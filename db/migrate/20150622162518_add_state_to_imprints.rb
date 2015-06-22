class AddStateToImprints < ActiveRecord::Migration
  def up
    add_column :imprints, :state, :string
    Imprint.unscoped.where(approved: true).update_all(state: :approved)
    remove_column :imprints, :approved
  end

  def down
    add_column :imprints, :approved, :boolean
    Imprint.unscoped.where(state: 'approved').update_all(approved: true)
    remove_column :imprints, :state
  end
end
