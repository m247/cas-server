require File.expand_path('../../spec_helper', __FILE__)

module CASServer
  module Validate
    describe Service do
      before(:each) do
        @service = Service.new do |s|
          s.success { 'success' }
          s.failure { 'failure' }
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
          @app = double('Sinatra::Base app')
          @app.stub(:params).and_return({})

          CASServer.configuration.ssl.ca_file = ''
        end
        describe "invalid service ticket" do
          it "should return failure" do
            @service.call(@app).should == 'failure'
          end
        end
        describe "valid service ticket" do
          before(:each) do
            @ticket = double('ServiceTicket')
            @ticket.stub(:username).and_return('test')
            @ticket.stub(:proxy_granting_ticket).and_return(nil)
            ServiceTicket.stub!(:validate!).and_return(@ticket)
          end
          it "should return success" do
            @service.call(@app).should == 'success'
          end
        end
      end
    end
  end
end
