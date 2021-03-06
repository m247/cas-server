require File.expand_path('../../spec_helper', __FILE__)

module CASServer
  module Validate
    describe Proxy do
      before(:each) do
        @proxy = Proxy.new do |p|
          p.success { 'success' }
          p.failure { |msg| msg }
        end
      end
      describe ".new" do
        it "should set success proc" do
          @proxy.instance_variable_get("@success").should_not be_nil
        end
        it "should set failure proc" do
          @proxy.instance_variable_get("@failure").should_not be_nil
        end
      end
      describe "#call" do
        before(:each) do
          @params = Hash.new
          @app = double('Sinatra::Base app')
          @app.stub(:params).and_return(@params)

          CASServer.configuration.ssl.ca_file = ''
        end
        describe "without proxy ticket" do
          it "should return failure" do
            @proxy.call(@app).should == 'INVALID_REQUEST'
          end
        end
        describe "invalid proxy ticket" do
          before(:each) do
            @params['ticket'] = 'PT-BLAHBLAH'
          end
          it "should return failure" do
            @proxy.call(@app).should == 'INVALID_TICKET'
          end
        end
        describe "valid proxy ticket" do
          before(:each) do
            @ticket = double('ProxyTicket')
            @ticket.stub(:username).and_return('test')
            @ticket.stub(:proxy_granting_ticket).and_return(nil)
            @ticket.stub(:granted_by_ticket).and_return(nil)
            @ticket.stub(:granted_by_cookie).and_return(nil)
            ProxyTicket.stub!(:validate!).and_return(@ticket)
          end
          it "should return success" do
            @proxy.call(@app).should == 'success'
          end
        end
      end
    end
  end
end
