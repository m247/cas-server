require File.expand_path('../../spec_helper', __FILE__)

module CASServer
  module Authenticator
    describe SQL do
      before(:each) do
        @auth = SQL.new({
          :database => 'sqlite3:db/accounts.sqlite3',
          :users_table => 'accounts',
          :username_column => 'username',
          :password_column => 'password',
          :crypted_password => 'md5',
          :locked => proc { |acct| acct.locked == 1 },
          :extra_attributes => []
        })
      end
      describe ".defaults" do
        it "should have :users_table = 'users'" do
          SQL.defaults[:users_table].should == 'users'
        end
      end
      describe "@options" do
        before(:each) do
          @options = @auth.instance_variable_get("@options")
        end
        it "should override default :users_table" do
          @options[:users_table].should == 'accounts'
        end
      end
    end
  end
end
