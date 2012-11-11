class AddExtraFirldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :gender, :string
    add_column :users, :connection_id, :integer
  end
end
