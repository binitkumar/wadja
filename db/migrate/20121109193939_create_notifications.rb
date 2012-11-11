class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :contact_id
      t.text :message
      t.string :request

      t.timestamps
    end
  end
end
