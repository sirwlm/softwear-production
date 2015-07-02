class AddProductionManagerApproval < ActiveRecord::Migration
  def change
    add_column :imprints, :require_manager_signoff, :boolean, index: true
  end
end
