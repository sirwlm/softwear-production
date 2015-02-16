class AddNameAndDescriptionToImprints < ActiveRecord::Migration
  def change
    add_column :imprints, :name, :string
    add_column :imprints, :description, :text
  end
end
