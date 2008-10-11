module Merb
  module PhotosHelper
    def vote_count(photo)
      curl = Gchart.pie(
        :size => '400x200',
        :title => "Oneable Results",
        :legend => [ 'Not One', 'One' ],
        :data => [ photo.zero_votes, photo.one_votes ],
        :theme => :pastel
      )
      "<img src='#{curl}' alt='Chart Results' />"
    end
  end
end # Merb
