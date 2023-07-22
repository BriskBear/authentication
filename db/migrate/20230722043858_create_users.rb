class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :username
      t.string :password_digest
      t.integer :confirmed_at

      t.integer :created_at
      t.integer :updated_at
    end

    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
  end
end
