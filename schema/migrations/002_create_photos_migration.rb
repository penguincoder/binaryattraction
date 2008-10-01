class CreatePhotosMigration < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.string :filename
      t.integer :user_id
      t.string :owner_token
      t.datetime :created_at
    end
    add_index :photos, :user_id
    add_index :photos, :owner_token
  end

  def self.down
    drop_table :photos
  end
end
