class PhotoFlag < ActiveRecord::Base
  belongs_to :photo, :counter_cache => true
  belongs_to :user
  validates_uniqueness_of :user_id, :scope => :photo_id
end
