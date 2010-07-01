require File.expand_path('../../spec_helper', __FILE__)

module CASServer
  describe TicketGrantingCookie do
    before(:each) do
      @klass = TicketGrantingCookie
    end

    describe ".prefix" do
      it "should be TGC-" do
        TicketGrantingCookie.prefix.should == 'TGC-'
      end
    end

    it_should_behave_like "GenericTicket"
    it_should_behave_like "ExpiringTicket"

    describe ".valid?" do
      before(:each) do
        @tgc = TicketGrantingCookie.create(:username => 'testing')
        @name = @tgc.name
      end
      it "should be with unexpired ticket" do
        TicketGrantingCookie.should be_valid(@name)
      end
      it "should not be valid with expired ticket" do
        @tgc.expire!
        TicketGrantingCookie.should_not be_valid(@name)
      end
    end
    describe ".create" do
      before(:each) do
        @tgc = TicketGrantingCookie.new
        @tgc.valid?
      end
      it "should require username" do
        @tgc.errors.on(:username).should have_at_least(1).error
      end
    end
  end
end
