require File.expand_path('../../spec_helper', __FILE__)

module CASServer
  describe ProxyTicket do
    before(:each) do
      @klass = ProxyTicket
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
        ServiceTicket.create(:service => 'http://test.com', :username => 'testing')
      end
      it "should return service tickets" do
        ProxyTicket.unexpired.first.should be_kind_of(ServiceTicket)
      end
    end
    describe ".expired" do
      before(:each) do
        ServiceTicket.create(:service => 'http://test.com', :username => 'testing').expire!
      end
      it "should return service tickets" do
        ProxyTicket.expired.first.should be_kind_of(ServiceTicket)
      end
    end
  end
end
