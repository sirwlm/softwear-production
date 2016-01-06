class CreateDigitalPrintUsers < ActiveRecord::Migration
  def change
    create_table :digital_print_users do |t|
      t.integer :user_id
      t.integer :digital_print_id

      t.timestamps null: false
    end

    add_index :digital_print_users, :user_id
    add_index :digital_print_users, :digital_print_id
  end
end
