module Merb
  module VotesHelper
    def stat_chart
      curl = Gchart.pie(
        :size => '415x275',
        :title => "Voting results for #{@user.votes.size} photos. Oneness #{"%.1f%%" % (@user.votes.select { |v| v.one? }.size.to_f / @user.votes.size.to_f * 100.0)}",
        :legend => [ "Not One (#{@user.votes.select { |v| v.zero? }.size})", "One (#{@user.votes.select { |v| v.one? }.size})" ],
        :data => [ @user.votes.select { |v| v.zero? }.size, @user.votes.select { |v| v.one? }.size ],
        :theme => :pastel
      )
      "<img src='#{curl}' alt='Chart Results' />"
    end
  end
end # Merb