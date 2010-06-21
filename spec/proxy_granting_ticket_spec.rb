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
    describe "after ProxyGrantingTicket#save" do
      it "should not be nil" do
        @pgt.proxy_granting_ticket_iou.should_not be_nil
      end
      it "should be saved" do
        @pgt.proxy_granting_ticket_iou.should be_saved
      end
    end
    describe "after ProxyGrantingTicket#destroy" do
      before(:each) do
        @name = @pgt.proxy_granting_ticket_iou.name
        @pgt.destroy!
      end
      it "should not exist" do
        ProxyGrantingTicketIou.get(@name).should be_nil
      end
    end
  end
end
