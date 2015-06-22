class AddTypeToImprints < ActiveRecord::Migration
  def up
    add_column :imprints, :type, :string
    Imprint.unscoped.update_all type: 'Print'
  end

  def down
    remove_column :imprints, :type
  end
end
