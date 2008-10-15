class PhotoFlagMigration < ActiveRecord::Migration
  def self.up
    create_table :photo_flags do |t|
      t.integer :user_id, :photo_id
      t.string :session_id
    end
    add_index :photo_flags, :user_id
    add_index :photo_flags, :photo_id
    add_column :photos, :photo_flags_count, :integer, :default => 0
  end

  def self.down
    drop_table :photo_flags
    remove_column :photos, :photo_flags_count
  end
end
