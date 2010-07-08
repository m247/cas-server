require File.expand_path('../../spec_helper', __FILE__)

module CASServer
  describe ProxyGrantingTicket do
    before(:each) do
      @klass = ProxyGrantingTicket
    end

    def default_options
      {:proxy => 'https://test-proxy.com'}
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
    describe "#granted_proxy_tickets" do
      before(:each) do
        @pgt = ProxyGrantingTicket.new
        @pgt.save
        @pt = ProxyTicket.create(:service => 'http://test.com', :username => 'testing')
        @pgt.granted_proxy_tickets << @pt
        @pgt.save

        @subject = ProxyGrantingTicket.get(@pgt.name)
      end
      it "should not be empty" do
        @subject.granted_proxy_tickets.should_not be_empty
      end
      it "should include a proxy ticket" do
        @subject.granted_proxy_tickets.should include(@pt)
      end
    end
  end
end
