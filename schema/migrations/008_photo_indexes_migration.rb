class PhotoIndexesMigration < ActiveRecord::Migration
  def self.up
    add_index :photos, :votes_count
    add_index :photos, :oneness
    add_index :photos, :approved
  end

  def self.down
    remove_index :photos, :votes_count
    remove_index :photos, :oneness
    remove_index :photos, :approved
  end
end
