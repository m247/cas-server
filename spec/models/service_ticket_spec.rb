require 'spec_helper'
require 'generic_ticket_spec'
require 'expiring_ticket_spec'

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
  describe ".validate!" do
    before(:each) do
      @st = ServiceTicket.create(:username => 'testing', :service => 'http://test.com/')
    end
    describe "valid service ticket" do
      before(:each) do
        @vst = ServiceTicket.validate!(@st.name, 'http://test.com/', false)
      end
      it "should return Service Ticket when successful" do
        @vst.should == @st
      end
      it "should expire Service Ticket when successful" do
        @vst.should be_expired
      end
    end
    describe "invalid service ticket" do
      it "should raise 'INVALID_REQUEST' for blank ticket" do
        lambda {
          ServiceTicket.validate!('', 'http://test.com/', false)
        }.should raise_exception(RuntimeError, 'INVALID_REQUEST')
      end
      it "should raise 'INVALID_TICKET' for non-service ticket" do
        lambda {
          ServiceTicket.validate!('LT-TESTING', 'http://test.com/', false)
        }.should raise_exception(RuntimeError, 'INVALID_TICKET')
      end
      it "should raise 'INVALID_TICKET' for non-existing ticket" do
        lambda {
          ServiceTicket.validate!('ST-TESTING', 'http://test.com/', false)
        }.should raise_exception(RuntimeError, 'INVALID_TICKET')
      end
    end
    describe "invalid service url" do
      it "should raise 'INVALID_SERVICE' if service doesn't match ticket" do
        lambda {
          ServiceTicket.validate!(@st.name, 'http://testing.com/', false)
        }.should raise_exception(RuntimeError, 'INVALID_SERVICE')
      end
    end
    describe "cookie granted service ticket" do
      before(:each) do
        @tgc = TicketGrantingCookie.create(:username => 'test')
        @st.granted_by_cookie = @tgc
        @st.save
      end
      it "should raise 'INVALID_TICKET' when renew is true" do
        lambda {
          ServiceTicket.validate!(@st.name, 'http://test.com/', true)
        }.should raise_exception(RuntimeError, 'INVALID_TICKET')
      end
      it "should return ServiceTicket when renew is false" do
        ServiceTicket.validate!(@st.name, 'http://test.com/', false).should == @st
      end
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
  describe "#url" do
    before(:each) do
      @st = ServiceTicket.new
    end
    it "should add query string if not present" do
      @st.service = "http://test.com"
      @st.url.should == "http://test.com?ticket=#{@st.name}"
    end
    it "should append to query string if present" do
      @st.service = "http://test.com/?group=testing"
      @st.url.should == "http://test.com/?group=testing&ticket=#{@st.name}"
    end
  end
end
