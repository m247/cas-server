require File.expand_path('../../spec_helper', __FILE__)

module CASServer
  module Credential
    describe Requestor do
      before(:each) do
        @requestor = Requestor.new do |r|
          r.login { "login" }
          r.gateway { "gateway" }
          r.logged_in { "logged_in" }
        end
      end
      describe ".new" do
        it "should set login proc" do
          @requestor.instance_variable_get("@login").should_not be_nil
        end
        it "should set gateway proc" do
          @requestor.instance_variable_get("@gateway").should_not be_nil
        end
        it "should set logged_in proc" do
          @requestor.instance_variable_get("@logged_in").should_not be_nil
        end
      end
      describe "#show_login_form?" do
        before(:each) do
          @params = {}
          @requestor.stub(:params).and_return(@params)
          @logged_in = false
        end
        def show_login_form
          @requestor.send(:show_login_form?, @logged_in)
        end
        def logged_in!
          @logged_in = true
        end
        it "should be true if not logged in" do
          show_login_form.should be_true
        end
        it "should be false if logged in" do
          logged_in!
          show_login_form.should be_false
        end
        describe "with renew set to true" do
          before(:each) do
            @params['renew'] = 'true'          
          end
          it "should be true if logged in" do
            show_login_form.should be_true
          end
          it "should be true if is logged in" do
            logged_in!
            show_login_form.should be_true
          end
        end
        describe "with service set" do
          before(:each) do
            @params['service'] = 'http://test.com/'
          end
          it "should be true if not logged in" do
            show_login_form.should be_true
          end
          it "should be false if logged in" do
            logged_in!
            show_login_form.should be_false
          end
          describe "and gateway set" do
            before(:each) do
              @params['gateway'] = 'true'
            end
            it "be true for gateway?" do
              @requestor.send(:gateway?).should be_true
            end
            it "should be false if not logged in" do
              show_login_form.should be_false
            end
            it "should be false if logged in" do
              logged_in!
              show_login_form.should be_false
            end
          end
        end
      end
      describe "#gateway?" do
        before(:each) do
          @params = {}
          @requestor.stub(:params).and_return(@params)
        end
        def gateway
          @requestor.send(:gateway?)
        end
        it "should be false" do
          gateway.should be_false
        end
        describe "with service set" do
          before(:each) do
            @params['service'] = 'http://test.com/'
          end
          it "should be false" do
            gateway.should be_false
          end
          describe "and gateway set" do
            before(:each) do
              @params['gateway'] = 'true'
            end
            it "should be true" do
              gateway.should be_true
            end
          end
        end
      end
      describe "#call" do
        before(:each) do
          @lt = double('LoginTicket')
          @app = double('Sinatra::Base app')
          @params = {} #double('Request Params')

          @app.stub(:params).and_return(@params)
          @app.stub(:logged_in?).and_return(false)

          # @params.stub(:[]).with(anything).and_return(nil)

          LoginTicket.stub!(:create).and_return(@lt)
        end
        # it "should hit params['service']" do
        #   @params.should_receive(:[]).with('service').and_return('http://test.com/')
        #   @requestor.call(@app)
        # end
        # it "should hit params['gateway']" do
        #   @params.should_receive(:[]).with('service').and_return('http://test.com/')
        #   @params.should_receive(:[]).with('gateway').and_return('true')
        #   @requestor.call(@app)
        # end
        # it "should hit params['renew']" do
        #   @params.should_receive(:[]).with('renew').and_return('true')
        #   @requestor.call(@app)
        # end
        describe "login response" do
          it "should return 'login'" do
            @params['renew'] = 'true'
            @requestor.call(@app).should == 'login'
          end
        end
        describe "gateway response" do
          it "should return 'gateway'" do
            @params.merge!('service' => 'http://test.com/', 'gateway' => 'true')
            @requestor.call(@app).should == 'gateway'
          end
        end
        describe "logged_in response" do
          it "should return 'logged_in'" do
            @app.should_receive(:logged_in?).and_return(true)
            @requestor.call(@app).should == 'logged_in'
          end
        end
      end
    end
  end
end
