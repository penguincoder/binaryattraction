require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Stats, "index action" do
  before(:each) do
    dispatch_to(Stats, :index)
  end
end