class Vote < ActiveRecord::Base
  belongs_to :photo
  belongs_to :user
  
  validates_presence_of :vote
  
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
end
