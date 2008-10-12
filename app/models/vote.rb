class Vote < ActiveRecord::Base
  belongs_to :photo
  belongs_to :user
  
  validate :unique_for_user
  validates_presence_of :photo_id
  
  attr_protected :user_id
  attr_protected :session_id
  
  after_create :update_photo_stats
  after_destroy :update_photo_stats
  
  ##
  # Checks if this vote is anonymous, or not an authenticated User vote.
  #
  def anonymous?
    self.user_id.nil?
  end
  
  ##
  # Convert this Vote to a number.
  #
  def to_i
    self.vote? ? 1 : 0
  end
  
  ##
  # Is this a 'no' vote.
  #
  def zero?
    self.to_i == 0
  end
  
  ##
  # Is this a 'yes' vote.
  #
  def one?
    self.to_i == 1
  end
  
  ##
  # Checks if a user has voted for a Photo. If you pass a User for user it will
  # check for an authenticated user, else it will look for an anonymous vote.
  #
  def self.voted_for?(photo, user)
    c = [ 'photo_id = :pid' ]
    v = { :pid => (photo.respond_to?('id') ? photo.id : photo) }
    if user.respond_to?('id')
      c << 'user_id = :uid'
      v[:uid] = user.id
    else
      c << 'session_id = :uid'
      v[:uid] = user
    end
    self.find :first, :conditions => [ c.join(' AND '), v ]
  end
  
  ##
  # Does a quick find and collect on the cast votes so you can find all voted
  # photo ids.
  #
  def self.voted_photo_ids(user)
    c = if user.respond_to?('id')
      "votes.user_id = #{user.id}"
    else
      "votes.session_id = '#{user}'"
    end
    self.find(:all, :conditions => c, :select => 'photo_id').collect { |v| v.photo_id }
  end
  
  protected
  
  ##
  # Make sure you can't vote on a photo more than once.
  #
  def unique_for_user
    if self.user.to_s.empty? and self.session_id.empty?
      self.errors.add(:vote, 'must have an owner')
    elsif self.user and Vote.voted_for?(self.photo, self.user)
      self.errors.add(:vote, 'has already been collected for this photo')
    elsif self.session_id and Vote.voted_for?(self.photo, self.session_id)
      self.errors.add(:anonymous, 'vote has already been collected')
    end
  end
  
  ##
  # Recalc the stats in the Photo for specific stats don't have to query the
  # database.
  #
  def update_photo_stats
    v = if self.frozen?
      -1
    else
      1
    end
    self.photo.votes_count += v
    if self.zero?
      self.photo.zero_votes += v
    else
      self.photo.one_votes += v
    end
    self.photo.save
  end
end
