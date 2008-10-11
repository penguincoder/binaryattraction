class User < ActiveRecord::Base
  attr_accessor :password, :password_confirmation
  attr_protected :user_name
  attr_protected :auth_token
  attr_protected :authorized
  
  validates_presence_of :user_name
  validates_length_of :user_name, :within => (6..32)
  validates_uniqueness_of :user_name
  validates_format_of :user_name, :with => /[\w_-]+/
  
  has_many :votes, :dependent => :destroy, :order => 'votes.photo_id ASC'
  has_many :photos, :dependent => :destroy, :through => :votes
  has_many :photo_favorites, :dependent => :destroy
  has_many :favorite_photos, :through => :photo_favorites, :class_name => 'Photo', :source => :photo
  
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
    Digest::SHA1.hexdigest("#{Merb::Config[:session_secret_key]}--#{str}--")
  end
  
  def voted_for?(photo)
    pid = photo.respond_to?('id') ? photo.id : photo
    self.votes.detect { |v| v.photo_id == pid }
  end
  
  protected
  
  def saltify_password
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
end
