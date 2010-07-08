require File.expand_path('../../spec_helper', __FILE__)

module CASServer
  describe ProxyTicket do
    before(:each) do
      @klass = ProxyTicket
    end

    def default_options
      {:service => 'http://test.com', :username => 'testing'}
    end

    describe ".prefix" do
      it "should be PT-" do
        ProxyTicket.prefix.should == 'PT-'
      end
    end
    describe ".valid_prefix?" do
      it "should accept service tickets" do
        ServiceTicket.valid_prefix?('ST-BLAHBLAH')
      end
    end

    it_should_behave_like "GenericTicket"
    it_should_behave_like "ExpiringTicket"

    describe ".unexpired" do
      before(:each) do
        ServiceTicket.create(default_options)
      end
      it "should return service tickets" do
        ProxyTicket.unexpired.first.should be_kind_of(ServiceTicket)
      end
    end
    describe ".expired" do
      before(:each) do
        ServiceTicket.create(default_options).expire!
      end
      it "should return service tickets" do
        ProxyTicket.expired.first.should be_kind_of(ServiceTicket)
      end
    end
    describe "#granted_by_ticket" do
      before(:each) do
        @pgt = ProxyGrantingTicket.new
        @pgt.save
        @pt = ProxyTicket.new(default_options)
        @pt.granted_by_ticket = @pgt
        @pt.save

        @subject = ProxyTicket.get(@pt.name)
      end
      it "should not be nil" do
        @subject.granted_by_ticket.should_not be_nil
      end
      it "should be a proxy granting ticket" do
        @subject.granted_by_ticket.should == @pgt
      end
    end
  end
end
