require 'spec_helper'

describe ServiceTicket do
  before(:each) do
    @klass = ServiceTicket
  end

  describe ".prefix" do
    it "should be ST-" do
      ServiceTicket.prefix.should == 'ST-'
    end
  end

  it_should_behave_like "GenericTicket"
  it_should_behave_like "ExpiringTicket"

  describe ".sanitize_service_url" do
    it "should strip off gateway" do
      ServiceTicket.sanitize_service_url("http://test.com/?gateway=true")
    end
    it "should strip off renew" do
      ServiceTicket.sanitize_service_url("http://test.com/?renew=true")
    end
    it "should strip off service" do
      ServiceTicket.sanitize_service_url("http://test.com/?service=http://srv-test.com")
    end
    it "should strip off ticket" do
      ServiceTicket.sanitize_service_url("http://test.com/?ticket=ST-sfdsflisfsesdfjsdhf")
    end
    it "should strip off multiple items" do
      ServiceTicket.sanitize_service_url("http://test.com/?service=http://srv-test.com&gateway=true")
    end
  end
  describe ".create" do
    before(:each) do
      @st = ServiceTicket.new
      @st.valid?
    end
    it "should require the service" do
      @st.errors.on(:service).should have_at_least(1).error
    end
    it "should require the username" do
      @st.errors.on(:username).should have_at_least(1).error
    end
  end
  describe "#service=" do
    before(:each) do
      @st = ServiceTicket.new
    end
    it "should assign service" do
      @st.service = "http://test.com"
      @st.service.should == "http://test.com"
    end
    it "should sanitize the service" do
      @st.service = "http://test.com/?gateway=true"
      @st.service.should == "http://test.com"
    end
  end
  describe "#service_matches?" do
    before(:each) do
      @st = ServiceTicket.new
      @st.service = "http://test.com/?renew=true"
    end
    it "should be true for sanitized service" do
      @st.service_matches?("http://test.com").should be_true
    end
    it "should be true for unsanitized service" do
      @st.service_matches?("http://test.com/?renew=true").should be_true
    end
    it "should be false for unmatching service" do
      @st.service_matches?("http://testing.com").should be_false
    end
  end
end
