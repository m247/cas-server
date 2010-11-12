CASServer.configuration do
  # Maximum ticket lifetimes for expiring tickets
  # LoginTicket, ServiceTicket and TicketGrantingCookie
  # login_ticket.maximum_lifetime            = 300
  # service_ticket.maximum_lifetime          = 300
  # ticket_granting_cookie.maximum_lifetime  = 172800

  # SSL Certificate Authority File.
  # Describes the list of trusted CA's to be used when verifying proxy callbacks
  # ssl.ca_file = 'config/cacert.pem'

  # Set the database the CAS Server will use for tickets
  # database 'sqlite3:db/development.sqlite3'
  
  # Should usernames be converted to lowercase? 
  # use_lowecase_usernames

  # Give users a link to reset their password, enable this
  # forgot_password_url 'http://accounts.example.com/password-reset'

  # Configure user/password based authenticators
  # Each call to sql, ldap or active_directory will append another
  # authenticator to the list. Authenticators are added and checked
  # in the order in which they are added below.
  #
  # General Authenticator Options
  #  +:locked+              Proc object which is passed a copy of the
  #                         account information retrieved from the
  #                         source to check if the account is locked.
  #  +:extra_attributes+    Array of extra fields from the account
  #                         information to return with the Account.
  #  +:fixed_attributes+    Hash of predefined attributes to include
  #                         in +:extra_attributes+.
  authenticators do
    # SQL Authenticator Options
    #  +:database+          URI or hash of database connection details.
    #  +:users_table+       Database table with the login information. Default 'users'.
    #  +:username_column+   Column in the +users_table+ with the username. Default 'username'.
    #  +:password_column+   Column in the +users_table+ with the password. Default 'password'.
    #  +:crypted_password+  Password hashing method, options: plain, md5, sha1, sha512. Default 'plain'.
    # sql << {
    #   :database => 'sqlite3:db/accounts.sqlite3',
    #   :users_table => 'accounts',
    #   :username_column => 'username',
    #   :password_column => 'password',
    #   :crypted_password => 'md5',
    #   :locked => proc { |acct| acct.locked == 1 },
    #   :extra_attributes => [],
    #   :fixed_attributes => { :admin => true }
    # }
    #
    # LDAP Authenticator Options
    #   +:host+                 Host name or IP address.
    #   +:port+                 Server port. Default '389'.
    #   +:base+                 Base distinguished name
    #   +:encryption+           Encryption method to use, options: nil, :simple_tls.
    #   +:filter+               Filter expression. Default '(objectClass=person)'.
    #   +:auth_user+            Authenticator user name.
    #   +:auth_password+        Authenticator user password.
    #   +:username_attribute+   Attribute with the username. Default 'cn'.
    # ldap << {
    #   :host => 'ldap.example.net',
    #   :port => 389,
    #   :base => 'dc=example,dc=net',
    #   :filter => '(objectClass=person)',
    #   :username_attribute => 'cn'
    # }
    #
    # ActiveDirectory Authenticator Options
    # same options as LDAP authenticator with the following differences:
    #   +:username_attribute+   Attribute with the username. Default 'sAMAccountName'.
    #   +:locked+               Defaults to lock accounts with ACCOUNT_DISABLE flag set.
    # active_directory << {
    #   :host => 'ad.example.com',
    #   :port => 636,
    #   :base => 'dc=example,dc=net',
    #   :filter => '(objectClass=person) & !(msExchHideFromAddressLists=TRUE)',
    #   :auth_user => 'authenticator',
    #   :auth_password => 'password',
    #   :encryption => :simple_tls,
    # }
  end

  # Trust authenticators
  # ** not yet implemented **
  # trust_authenticators do
  # end
end
