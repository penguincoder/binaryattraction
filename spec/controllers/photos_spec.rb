require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Photos, "index action" do
  before(:each) do
    dispatch_to(Photos, :index)
  end
end