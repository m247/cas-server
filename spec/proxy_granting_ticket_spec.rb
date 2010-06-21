require 'spec_helper'
require 'generic_ticket_spec'

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

  describe "#proxy_granting_ticket_iou" do
    before(:each) do
      @pgt = ProxyGrantingTicket.new
      @pgt.save
    end
    it "should not be nil after ProxyGrantingTicket#save" do
      @pgt.proxy_granting_ticket_iou.should_not be_nil
    end
    it "should be saved after ProxyGrantingTicket#save" do
      @pgt.proxy_granting_ticket_iou.should be_saved
    end
  end
end
