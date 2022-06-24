class CreateDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :details do |t|
      t.string :name, null: false
      t.integer :quantity
      t.integer :price
      t.text :remark
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
