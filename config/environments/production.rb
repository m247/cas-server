CASServer.configuration do
  database 'sqlite3:db/development.sqlite3'

  # authenticators do
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
  #     :extra_attributes => %w(cn)
  #   }
  # end
end
