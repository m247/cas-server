require 'spec_helper'

describe ProxyGrantingTicket do
  before(:each) do
    @klass = ProxyGrantingTicket
  end

  describe ".prefix" do
    it "should be PGT-" do
      ProxyGrantingTicket.prefix.should == 'PGT-'
    end
  end

  it_should_behave_like "GenericTicket"
end
