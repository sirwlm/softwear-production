class AddSoftwearCrmIdToImprintGroups < ActiveRecord::Migration
  def change
    add_column :imprint_groups, :softwear_crm_id, :integer
  end
end
