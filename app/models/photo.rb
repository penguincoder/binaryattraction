class Photo < ActiveRecord::Base
  #property :id, Integer, :serial => true
  #property :filename, String
  #property :email_hash, String
  #property :created_at, DateTime
  validates_presence_of :filename
  has_many :votes, :dependent => :destroy
end
