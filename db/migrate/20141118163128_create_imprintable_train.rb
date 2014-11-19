class CreateImprintableTrain < ActiveRecord::Migration
  def change
    create_table :imprintable_trains do |t|
      t.integer :job_id
      t.string :state
      t.timestamps
    end
  end
end
