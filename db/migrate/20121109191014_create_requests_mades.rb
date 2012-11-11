class CreateRequestsMades < ActiveRecord::Migration
  def change
    create_table :requests_mades do |t|
      t.integer :user_id
      t.integer :requested_user_id
      t.integer :type_id
      t.integer :status_id
      t.datetime :date_sent

      t.timestamps
    end
  end
end
