class PhotoFavoriteMigration < ActiveRecord::Migration
  def self.up
    create_table :photo_favorites do |t|
      t.integer :photo_id, :user_id
    end
    add_index :photo_favorites, :photo_id
    add_index :photo_favorites, :user_id
  end

  def self.down
    drop_table :photo_favorites
  end
end
