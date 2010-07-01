require File.expand_path('../../spec_helper', __FILE__)

module CASServer
  module Credential
    describe Acceptor do
      before(:each) do
        @acceptor = Acceptor.new do |a|
          a.redirect { "redirect" }
          a.success  { "success" }
          a.failure  { |msg| msg }
        end
      end
      describe ".new" do
        it "should set redirect proc" do
          @acceptor.instance_variable_get("@redirect").should_not be_nil
        end
        it "should set success proc" do
          @acceptor.instance_variable_get("@success").should_not be_nil
        end
        it "should set failure proc" do
          @acceptor.instance_variable_get("@failure").should_not be_nil
        end
      end
      describe "#call" do
        before(:each) do
          @app = double('Sinatra::Base app')
          @params = {'lt' => 'LT-TESTING', 'username' => 'test', 'password' => 'testing'}
          @request = double('Test Request')
          @account = double('Test Account')
          @authenticator = double('Test Authenticator')

          @app.stub(:params).and_return(@params)
          @app.stub(:request).and_return(@request)
          @app.stub(:authenticators).and_return([@authenticator])
          @app.stub(:trust_authenticators).and_return([])

          @account.stub(:username).and_return('test')
          @account.stub(:extra).and_return({})
          @account.stub(:locked?).and_return(false)

          @authenticator.stub(:authenticate).with('test', 'testing', anything, @request).and_return(@account)
        end
        describe "invalid login ticket" do
          before(:each) do
            LoginTicket.stub!(:valid?).with('LT-TESTING').and_return(false)
          end
          it "should fail with reason 'Invalid Credentials'" do
            @acceptor.call(@app).should == 'Invalid Credentials'
          end
        end
        describe "valid login ticket" do
          before(:each) do
            LoginTicket.stub!(:valid?).with('LT-TESTING').and_return(true)
          end
          describe "invalid credentials" do
            before(:each) do
              @account.stub(:nil?).and_return(true)
            end
            it "should fail with reason 'Invalid Credentials'" do
              @acceptor.call(@app).should == 'Invalid Credentials'
            end
          end
          describe "locked account" do
            before(:each) do
              @account.stub(:locked?).and_return(true)
            end
            it "should fail with reason 'Account test is locked'" do
              @acceptor.call(@app).should match(/Account "([^\"]*)" is locked/)
            end
          end
          describe "valid account" do
            before(:each) do
              @app.should_receive(:ticket_granting_cookie=)
            end
            it "should result in success" do
              @acceptor.call(@app).should == 'success'
            end
            describe "service set" do
              before(:each) do
                @params['service'] = 'http://test.com/'
              end
              it "should result in redirect" do
                @acceptor.call(@app).should == 'redirect'
              end
            end
          end
        end
      end
    end
  end
end
