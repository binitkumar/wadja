class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :user_id
      t.string :network
      t.string :token
      t.string :secret

      t.timestamps
    end
  end
end
