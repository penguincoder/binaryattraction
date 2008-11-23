class FacebookDataMigration < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_id, :bigint
    add_index :users, :facebook_id
    add_column :photos, :facebook_id, :bigint
    add_index :photos, :facebook_id
  end

  def self.down
    remove_column :users, :facebook_id
    remove_column :photos, :facebook_id
  end
end
