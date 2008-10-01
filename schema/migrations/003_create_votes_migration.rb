class CreateVotesMigration < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.integer :photo_id, :user_id
      t.boolean :vote
    end
    add_index :votes, :photo_id
    add_index :votes, :user_id
  end

  def self.down
    drop_table :votes
  end
end
