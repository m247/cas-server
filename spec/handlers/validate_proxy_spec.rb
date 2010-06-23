require 'spec_helper'

module Validate
  describe Proxy do
    before(:each) do
      @proxy = Proxy.new do |p|
        p.success { 'success' }
        p.failure { 'failure' }
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
        @app = double('Sinatra::Base app')
        @opt = double('Sinatra::Base app options')
        @app.stub(:params).and_return({})
        @app.stub(:options).and_return(@opt)
        @opt.stub(:ca_file).and_return('')
      end
      describe "invalid proxy ticket" do
        it "should return failure" do
          @proxy.call(@app).should == 'failure'
        end
      end
      describe "valid proxy ticket" do
        before(:each) do
          @ticket = double('ProxyTicket')
          @ticket.stub(:username).and_return('test')
          @ticket.stub(:proxy_granting_ticket).and_return(nil)
          ProxyTicket.stub!(:validate!).and_return(@ticket)
        end
        it "should return success" do
          @proxy.call(@app).should == 'success'
        end
      end
    end
  end
end
