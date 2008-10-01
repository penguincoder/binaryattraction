require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Votes, "index action" do
  before(:each) do
    dispatch_to(Votes, :index)
  end
end