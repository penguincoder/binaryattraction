class User < ActiveRecord::Base
  attr_accessor :password, :password_confirmation
  attr_protected :user_name
  attr_protected :auth_token
  attr_protected :authorized
  
  validates_presence_of :user_name, :if => lambda { |x| x.facebook_id.nil? }
  validates_length_of :user_name, :within => (6..32), :if => lambda { |x| x.facebook_id.nil? }
  validates_uniqueness_of :user_name, :if => lambda { |x| x.facebook_id.nil? }
  validates_format_of :user_name, :with => /[\w_-]+/, :if => lambda { |x| x.facebook_id.nil? }
  validates_presence_of :facebook_id, :if => lambda { |x| x.user_name.to_s.empty? }
  
  has_many :photos, :dependent => :destroy
  has_many :votes, :dependent => :destroy, :order => 'votes.photo_id ASC'
  has_many :voted_photos, :through => :votes, :class_name => 'Photo', :source => :photo
  has_many :photo_favorites, :dependent => :destroy
  has_many :favorite_photos, :through => :photo_favorites, :class_name => 'Photo', :source => :photo
  has_many :photo_flags, :dependent => :destroy
  
  before_validation :saltify_password
  
  def authenticated_against?(str)
    ss = User.salted_string(str)
    if self.auth_token.to_s == ss
      true
    else
      false
    end
  end
  
  def self.salted_string(str)
    Digest::SHA1.hexdigest("#{@@salt}--#{str}--")
  end
  
  def voted_for?(photo)
    pid = photo.respond_to?('id') ? photo.id : photo
    self.votes.detect { |v| v.photo_id == pid }
  end
  
  protected
  
  def saltify_password
    return true unless self.facebook_id.nil?
    if !self.password.to_s.empty?
      if self.password.to_s.size < 6
        self.errors.add(:password, 'is too short')
      elsif self.password != self.password_confirmation
        self.errors.add(:passwords, 'do not match')
      else
        self.auth_token = User.salted_string(self.password)
      end
    elsif self.auth_token.to_s.empty?
      self.errors.add(:password, 'is missing')
    end
  end
  
  private
  
  @@salt = '297d94827e16917483c130b7e7f4fd44d605dcdb'
end
