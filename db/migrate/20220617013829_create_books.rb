class CreateBooks < ActiveRecord::Migration[6.0]
  def change
    create_table :books do |t|
      t.string :name, null: false
      t.integer :number, null: false
      t.string :keyword1
      t.string :keyword2
      t.string :keyword3
      t.string :keyword4
      t.string :keyword5

      t.timestamps
    end
  end
end
