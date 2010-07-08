require File.expand_path('../spec_helper', __FILE__)

shared_examples_for "ExpiringTicket" do
  describe ".maximum_lifetime" do
    before(:each) do
      @klass.maximum_lifetime = nil
    end
    it "should respond with default value" do
      @klass.maximum_lifetime.should == 300
    end
  end
  describe ".maximum_lifetime=" do
    it "should set the maximum lifetime" do
      @klass.maximum_lifetime = 500
      @klass.maximum_lifetime.should == 500
    end
  end
  describe ".expires_at" do
    it "should be :maximum_lifetime into the future" do
      t = @klass.new(default_options)
      t.expires_at.to_i.should == (Time.now.utc + @klass.maximum_lifetime).to_i
    end
  end
  describe ".expired" do
    it "should respond" do
      @klass.should respond_to(:expired)
    end
  end
  describe ".unexpired" do
    it "should respond" do
      @klass.should respond_to(:unexpired)
    end
  end
  describe "#expire!" do
    it "should expire the ticket" do
      t = @klass.new(default_options)
      t.expire!
      t.should be_expired
    end
  end
  describe "#expired?" do
    before(:each) do
      @expiring_ticket = @klass.new(default_options)
    end
    it "should be false when not expired" do
      @expiring_ticket.should_not be_expired
    end
    it "should be true after expiring" do
      @expiring_ticket.expire!
      @expiring_ticket.should be_expired
    end
  end
end
