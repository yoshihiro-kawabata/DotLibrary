class CreateUsersAuthorities < ActiveRecord::Migration[6.0]
  def change
    create_table :users_authorities do |t|
      t.references :user, null: false, foreign_key: true
      t.references :authority, null: false, foreign_key: true

      t.timestamps
    end
  end
end
