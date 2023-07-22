class CreateActiveSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :active_sessions do |t|
      t.references :user, null: false, foreign_key: {on_delete: :cascade}

      t.integer :created_at
      t.integer :updated_at
    end
  end
end
