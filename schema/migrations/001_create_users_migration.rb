class CreateUsersMigration < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :user_name, :limit => 32
      t.string :auth_token
      t.boolean :administrator
      t.datetime :created_at
    end
    add_index :users, :user_name
  end

  def self.down
    drop_table :users
  end
end
