require File.expand_path('../../spec_helper', __FILE__)

module CASServer
  describe ProxyGrantingTicketIou do
    before(:each) do
      @klass = ProxyGrantingTicketIou
    end

    def default_options
      {}
    end

    describe ".prefix" do
      it "should be PGTIOU-" do
        ProxyGrantingTicketIou.prefix.should == 'PGTIOU-'
      end
    end

    it_should_behave_like "GenericTicket"
  end
end
