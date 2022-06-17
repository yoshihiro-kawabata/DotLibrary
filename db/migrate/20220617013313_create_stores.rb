class CreateStores < ActiveRecord::Migration[6.0]
  def change
    create_table :stores do |t|
      t.string :name, null: false
      t.integer :sub_number, null: false
      t.string :phone, null: false
      t.string :fax
      t.string :manager
      t.string :email, null: false
      t.string :address, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
