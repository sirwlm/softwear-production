class AddApprovedToImprints < ActiveRecord::Migration
  def change
    add_column :imprints, :approved, :boolean

    ActiveRecord::Base.connection.execute(
    %(
      UPDATE imprints
      SET approved = true;
    ))
  end
end
