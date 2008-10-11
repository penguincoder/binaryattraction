class CreatePhotosMigration < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.string :filename, :content_type, :email_hash
      t.integer :width, :height
      t.datetime :created_at
      t.boolean :approved
    end
    add_index :photos, :email_hash
  end

  def self.down
    drop_table :photos
  end
end
