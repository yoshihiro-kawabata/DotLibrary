class CreateAuthorities < ActiveRecord::Migration[6.0]
  def change
    create_table :authorities do |t|
      t.integer :level, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
