require 'spec_helper'

describe Configuration do
  before(:each) do
    @configuration = Configuration.new
  end
  describe "#login_ticket" do
    it "should set return LoginTicket" do
      @configuration.login_ticket.should == LoginTicket
    end
  end
  describe "#service_ticket" do
    it "should return ServiceTicket" do
      @configuration.service_ticket.should == ServiceTicket
    end
  end
  describe "#ticket_granting_cookie" do
    it "should return TicketGrantingCookie" do
      @configuration.ticket_granting_cookie.should == TicketGrantingCookie
    end
  end
  describe "#ssl" do
    it "should be be an ostruct" do
      @configuration.ssl.should be_kind_of(OpenStruct)
    end
    it "should allow setting ca_file" do
      @configuration.ssl.ca_file = 'testing'
      @configuration.ssl.ca_file.should == 'testing'
    end
  end
  describe "#database" do
    it "should allow setting of database URI" do
      @configuration.database = 'sqlite:db/testing.db'
      @configuration.database.should == 'sqlite:db/testing.db'
    end
  end
  describe "#authenticators" do
    before(:each) do
      @configuration.authenticators do
        sql << {
          :database => 'postgres://username:password@localhost/auth_source',
          :user_table => 'accounts',
          :username_column => 'username',
          :password_column => 'password',
          :crypted_password => 'md5',
          :extra_attributes => ['name', 'mail']
        }
        ldap << {
          :host => 'ldap.example.net',
          :port => 389,
          :base => 'dc=example,dc=net',
          :filter => '(objectClass=person)',
          :username_attribute => 'cn'
        }
      end
      @auth = @configuration.authenticators
    end
    describe "#reset!" do
      it "should clear the authenticators list" do
        @configuration.authenticators.reset!
        @configuration.authenticators.all.should be_empty
      end
    end
    describe "#sql" do
      before(:each) do
        @sql = @auth.get(:sql).first
      end
      it "should set an SQL config block" do
        @sql.should_not be_nil
      end
      it "should set database" do
        @sql[:database].should == 'postgres://username:password@localhost/auth_source'
      end
      it "should set user_table" do
        @sql[:user_table].should == 'accounts'
      end
    end
    describe "#ldap" do
      before(:each) do
        @ldap = @auth.get(:ldap).first
      end
      it "should set an LDAP config block" do
        @ldap.should_not be_nil
      end
      it "should set database" do
        @ldap[:host].should == 'ldap.example.net'
      end
      it "should set user_table" do
        @ldap[:port].should == 389
      end
      describe "multiple" do
        before(:each) do
          @auth.ldap << {
            :host => 'ldap.example.com',
            :port => 636,
            :base => 'dc=example,dc=net',
            :filter => '(objectClass=person)',
            :auth_user => 'authenticator',
            :auth_password => 'password',
            :encryption => 'simple_tls',
            :username_attribute => 'cn'
          }
        end
        it "should have two ldap authenticators" do
          @auth.get(:ldap).count.should == 2
        end
        it "should keep the first in place" do
          @auth.get(:ldap).first[:host].should == 'ldap.example.net'
        end
        it "should append the second" do
          @auth.get(:ldap).last[:host].should == 'ldap.example.com'
        end
      end
    end
  end
end
