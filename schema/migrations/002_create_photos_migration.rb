class CreatePhotosMigration < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.string :filename, :content_type, :email_hash
      t.integer :width, :height, :user_id
      t.datetime :created_at
      t.boolean :approved, :default => false
    end
    add_index :photos, :email_hash
    add_index :photos, :user_id
  end

  def self.down
    drop_table :photos
  end
end
