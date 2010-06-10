require 'spec_helper'

describe ProxyGrantingTicketIou do
  before(:each) do
    @klass = ProxyGrantingTicketIou
  end

  describe ".prefix" do
    it "should be PGTIOU-" do
      ProxyGrantingTicketIou.prefix.should == 'PGTIOU-'
    end
  end

  it_should_behave_like "GenericTicket"
end
