class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :country_id
      t.string :username
      t.string :name
      t.string :email
      t.boolean :email_verified
      t.date :birth_date
      t.string :password

      t.timestamps
    end
  end
end
