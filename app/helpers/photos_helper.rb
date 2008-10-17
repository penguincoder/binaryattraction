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
    
    def stat_chart
      curl = Gchart.pie(
        :size => '415x275',
        :title => "Voting results for #{@photo_ids.size} photos. Oneness #{"%.1f%%" % (@votes.select { |v| v.one? }.size.to_f / @votes.size.to_f * 100.0)}",
        :legend => [ "Not One (#{@votes.select { |v| v.zero? }.size})", "One (#{@votes.select { |v| v.one? }.size})" ],
        :data => [ @votes.select { |v| v.zero? }.size, @votes.select { |v| v.one? }.size ],
        :theme => :pastel
      )
      "<img src='#{curl}' alt='Chart Results' />"
    end
  end
end # Merb
