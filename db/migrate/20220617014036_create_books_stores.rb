class CreateBooksStores < ActiveRecord::Migration[6.0]
  def change
    create_table :books_stores do |t|
      t.references :store, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :price, null: false
      t.text :rimit, null: false

      t.timestamps
    end
  end
end
