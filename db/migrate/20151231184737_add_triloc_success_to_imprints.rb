class AddTrilocSuccessToImprints < ActiveRecord::Migration
  def change
    add_column :imprints, :triloc_result, :string
  end
end
