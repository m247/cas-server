require File.expand_path('../../spec_helper', __FILE__)

module CASServer
  module Validate
    describe Service do
      before(:each) do
        @service = Service.new do |s|
          s.success { 'success' }
          s.failure { |msg| msg }
        end
      end
      describe ".new" do
        it "should set success proc" do
          @service.instance_variable_get("@success").should_not be_nil
        end
        it "should set failure proc" do
          @service.instance_variable_get("@failure").should_not be_nil
        end
      end
      describe "#call" do
        before(:each) do
          @params = {}
          @app = double('Sinatra::Base app')
          @app.stub(:params).and_return(@params)

          CASServer.configuration.ssl.ca_file = ''
        end
        describe "without service ticket" do
          it "should return failure" do
            @service.call(@app).should == 'INVALID_REQUEST'
          end
        end
        describe "invalid service ticket" do
          before(:each) do
            @params['ticket'] = 'ST-BLAHBLAH'
          end
          it "should return failure" do
            @service.call(@app).should == 'INVALID_TICKET'
          end
        end
        describe "valid service ticket" do
          before(:each) do
            @cookie = double('TicketGrantingCookie')
            @cookie.stub(:extra).and_return({:other => 'testing'})
            @ticket = double('ServiceTicket')
            @ticket.stub(:username).and_return('test')
            @ticket.stub(:proxy_granting_ticket).and_return(nil)
            @ticket.stub(:granted_by_cookie).and_return(@cookie)
            ServiceTicket.stub!(:validate!).and_return(@ticket)
          end
          it "should return success" do
            @service.call(@app).should == 'success'
          end
          it "should include the extras" do
            @service.success { |user, pgt, extra| extra.to_a.join(" ") }
            @service.call(@app).should == 'other testing'
          end
        end
      end
    end
  end
end
