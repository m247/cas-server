require 'spec_helper'

module Proxy
  describe Grantor do
    before(:each) do
      @grantor = Grantor.new do |g|
        g.success { 'success' }
        g.failure { |msg| msg }
      end
    end
    describe ".new" do
      it "should set success proc" do
        @grantor.instance_variable_get("@success").should_not be_nil
      end
      it "should set failure proc" do
        @grantor.instance_variable_get("@failure").should_not be_nil
      end
    end
    describe "#call" do
      before(:each) do
        @params = {}
        @app = double('Sinatra::Base app')
        @app.stub(:params).and_return(@params)
      end
      describe "invalid request" do
        describe "missing proxy granting ticket" do
          before(:each) do
            @params['targetService'] = 'http://testing.com/'
          end
          it "should return 'INVALID_REQUEST'" do
            @grantor.call(@app).should == 'INVALID_REQUEST'
          end
        end
        describe "missing target service" do
          before(:each) do
            @params['pgt'] = 'PGT-TESTING'
          end
          it "should return 'INVALID_REQUEST'" do
            @grantor.call(@app).should == 'INVALID_REQUEST'
          end
        end
      end
      describe "valid request" do
        before(:each) do
          @params['pgt'] = 'PGT-TESTING'
          @params['targetService'] = 'http://testing.com/'
        end
        describe "bad proxy granting ticket" do
          before(:each) do
            ProxyGrantingTicket.stub!(:validate!).and_return(nil)
          end
          it "should return 'BAD_PGT'" do
            @grantor.call(@app).should == 'BAD_PGT'
          end
        end
        describe "valid proxy granting ticket" do
          before(:each) do
            @pt = double('ProxyTicket')
            @st = double('ServiceTicket')
            @pgt = double('ProxyGrantingTicket')

            @pt.stub(:name).and_return('PT-TEST')
            @st.stub(:username).and_return('test')
            @pgt.stub(:service_ticket).and_return(@st)

            ProxyTicket.stub!(:create).and_return(@pt)
            ProxyGrantingTicket.stub!(:validate!).and_return(@pgt)
          end
          it "should return 'success'" do
            @grantor.call(@app).should == 'success'
          end
        end
      end
    end
  end
end
