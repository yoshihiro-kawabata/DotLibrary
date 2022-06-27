class CreateBooksProviders < ActiveRecord::Migration[6.0]
  def change
    create_table :books_providers do |t|
      t.references :provider, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.bigint :quantity, null: false
      t.boolean :hand_flg, null: false, default: false

      t.timestamps
    end
  end
end
