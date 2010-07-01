require File.expand_path('../../spec_helper', __FILE__)

module CASServer
  module Validate
    describe Plain do
      before(:each) do
        @plain = Plain.new do |p|
          p.success { 'success' }
          p.failure { 'failure' }
        end
      end
      describe ".new" do
        it "should set success proc" do
          @plain.instance_variable_get("@success").should_not be_nil
        end
        it "should set failure proc" do
          @plain.instance_variable_get("@failure").should_not be_nil
        end
      end
      describe "#call" do
        before(:each) do
          @app = double('Sinatra::Base app')
          @ticket = double('ServiceTicket')
          @params = {'ticket' => 'ST-TESTING', 'service' => 'http://test.com/'}

          @app.stub(:params).and_return(@params)
          @ticket.stub(:username).and_return('test')
        end
        describe "success" do
          before(:each) do
            ServiceTicket.stub!(:validate!).and_return(@ticket)
          end
          it "should return 'success'" do
            @plain.call(@app).should == 'success'
          end
        end
        describe "failure" do
          before(:each) do
            ServiceTicket.stub!(:validate!).and_raise(RuntimeError.new('TEST_ERROR'))
          end
          it "should return 'failure'" do
            @plain.call(@app).should == 'failure'
          end
        end
      end
    end
  end
end
