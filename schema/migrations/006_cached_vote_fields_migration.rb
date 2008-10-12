class CachedVoteFieldsMigration < ActiveRecord::Migration
  def self.up
    add_column :photos, :votes_count, :integer, :default => 0
    add_column :photos, :one_votes, :integer, :default => 0
    add_column :photos, :zero_votes, :integer, :default => 0
    add_column :photos, :oneness, :float, :precision => 1
  end

  def self.down
    remove_column :photos, :votes_count
    remove_column :photos, :one_votes
    remove_column :photos, :zero_votes
    remove_column :photos, :oneness
  end
end
