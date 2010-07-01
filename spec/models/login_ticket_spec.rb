require File.expand_path('../../spec_helper', __FILE__)

module CASServer
  describe LoginTicket do
    before(:each) do
      @klass = LoginTicket
    end

    describe ".prefix" do
      it "should be LT-" do
        LoginTicket.prefix.should == 'LT-'
      end
    end

    it_should_behave_like "GenericTicket"
    it_should_behave_like "ExpiringTicket"

    describe ".create" do
      it "should create a login ticket" do
        lt = LoginTicket.create
        lt.should be_saved
      end
    end

    describe ".valid?" do
      before(:each) do
        @lt = LoginTicket.create
        @name = @lt.name
      end
      it "should be with unexpired ticket" do
        LoginTicket.should be_valid(@name)
      end
      it "should not be valid with expired ticket" do
        @lt.expire!
        LoginTicket.should_not be_valid(@name)
      end
    end
  end
end
