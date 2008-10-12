class Photo < ActiveRecord::Base
  attr_accessor :email
  attr_accessor :file
  attr_protected :email_hash
  
  has_many :votes, :dependent => :destroy
  has_many :photo_favorites, :dependent => :destroy
  
  before_create :validate_image_sanity
  before_create :hashify_email
  before_save :set_oneness
  
  after_create :create_directories
  before_destroy :destroy_directories
  
  ##
  # Returns the path of the image relative to Merb's root.
  #
  def relative_directory
    "/photos/#{id.to_s[0,2]}/#{id.to_s[0,4]}/#{id}"
  end
  
  ##
  # Determines the base directory for all files in this model.
  #
  def base_directory
    "#{Merb.root}/public#{self.relative_directory}"
  end
  
  ##
  # Checks to see if the file is found on the filesystem.
  #
  def exist?
    File.exist? "#{self.base_directory}/#{self.filename}"
  end
  
  ##
  # Returns the full path to the file suitable for an image source.
  #
  def pathname
    "#{self.relative_directory}/#{self.filename}"
  end
  
  def self.next_available_votable_photo(user)
    pids = Vote.voted_photo_ids(user)
    c = if pids.empty?
      nil
    else
      "photos.id NOT IN (#{pids.join(',')})"
    end
    self.find :first, :conditions => c, :order => 'id ASC'
  end
  
  protected
  
  ##
  # Checks to make sure that the file exists and is an image.
  #
  def validate_image_sanity
    if self.file.empty? or self.file[:tempfile].nil?
      self.errors.add(:file, 'is not a file')
    elsif self.file[:content_type] !~ /image\/\w+/
      self.errors.add(:file, 'is not a supported type')
    elsif self.file[:size] and self.file[:size] > 3.megabytes
      self.errors.add(:file, 'is too big (3MB max)')
    end
    self.content_type = self.file[:content_type]
    
    begin
      @fstr = self.file[:tempfile].read
      iary = Magick::Image.from_blob(@fstr)
      self.filename = File.basename(self.file[:filename]).gsub(/[^\w._-]/, '')
      if iary.inspect.to_s =~ /(\d+)x(\d+)/
        self.width = $1
        self.height = $2
      end
      # resize to fit on the screen if it's too big... 600x600
      if self.width > 600 or self.height > 600
        iary.first.resize_to_fit!(600, 600)
        if iary.inspect.to_s =~ /(\d+)x(\d+)\+\d+\+\d+/
          self.width = $1
          self.height = $2
        end
        @fstr = iary.first.to_blob
      end
    rescue
      Merb.logger.error("Caught an exception saving an image:")
      Merb.logger.error("* #{$!}")
      self.errors.add(:file, 'File could not be read as an image')
    end if self.errors.empty?
    
    if self.errors.empty?
      true
    else
      false
    end
  end
  
  ##
  # Makes the directories and writes the file to disk.
  #
  def create_directories
    File.umask(0022)
    FileUtils.mkdir_p(base_directory) unless File.exist?(base_directory)
    File.open("#{base_directory}/#{self.filename}", "w") do |f|
      f.puts(@fstr)
    end
    File.chmod(0644, "#{base_directory}/#{self.filename}")
  end
  
  ##
  # Removes the directories and files associated with this model on destroy.
  #
  def destroy_directories
    return unless File.exists?(base_directory)
    Dir.foreach(base_directory) do |file|
      next if file =~ /^\.\.?$/
      File.delete(base_directory + '/' + file)
    end
    Dir.delete(base_directory)
  end
  
  ##
  # Renders the email into a hashed string for later retrieval.
  #
  def hashify_email
    email_hash = User.salted_string(email) unless email.to_s.empty?
    true
  end
  
  ##
  # Regenerates the calculated value of oneness.
  #
  def set_oneness
    self.oneness = (self.one_votes.to_f / self.votes_count.to_f * 100.0)
  end
end
