class AddCountToImprints < ActiveRecord::Migration
  def change
    add_column :imprints, :count, :integer
    Imprint.all.update_all('count = 1')
  end
end
