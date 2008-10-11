module Merb
  module VotesHelper
    def stat_chart
      curl = Gchart.pie(
        :size => '300x200',
        :title => "Voting results for #{@user.votes.size} photos",
        :legend => [ 'Not One', 'One' ],
        :data => [ @user.votes.select { |v| v.zero? }.size, @user.votes.select { |v| v.one? }.size ],
        :theme => :pastel
      )
      "<img src='#{curl}' alt='Chart Results' />"
    end
  end
end # Merb