class CreateBooksLibraries < ActiveRecord::Migration[6.0]
  def change
    create_table :books_libraries do |t|
      t.references :library, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :quantity
      t.text :remark

      t.timestamps
    end
  end
end
