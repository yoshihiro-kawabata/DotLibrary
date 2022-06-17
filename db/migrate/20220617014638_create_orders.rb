class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.text :title
      t.references :user, null: false, foreign_key: true
      t.string :user_name, null: false
      t.bigint :receive_user_id, null: false
      t.string :receive_user_name, null: false
      t.integer :number, null: false
      t.boolean :complete_flg, null: false, default: false
      t.text :rimit
      t.text :condition
      t.integer :price

      t.timestamps
    end
  end
end
