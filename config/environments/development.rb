CASServer.configuration do
  database = 'sqlite3:db/development.sqlite3'

  # authenticators do
  #   sql << {
  #     :database => 'postgres://username:password@localhost/auth_source',
  #     :user_table => 'accounts',
  #     :username_column => 'username',
  #     :password_column => 'password',
  #     :crypted_password => 'md5',
  #     :locked => proc { |acct| acct.locked < Time.now.utc },
  #     :extra_attributes => []
  #   }
  # 
  #   ldap << {
  #     :host => 'ldap.example.net',
  #     :port => 389,
  #     :base => 'dc=example,dc=net',
  #     :filter => '(objectClass=person)',
  #     :username_attribute => 'cn'
  #   }
  # 
  #   active_directory << {
  #     :host => 'ad.example.com',
  #     :port => 636,
  #     :base => 'dc=example,dc=net',
  #     :filter => '(objectClass=person) & !(msExchHideFromAddressLists=TRUE)',
  #     :auth_user => 'authenticator',
  #     :auth_password => 'password',
  #     :encryption => 'simple_tls',
  #     :username_attribute => 'sAMAccountName',
  #     :extra_attributes => %w(cn),
  #     :locked => proc { |acct| acct['userAccountControl'] & 0x002 == 0x002 }
  #   }
  # end
end
