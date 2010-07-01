CASServer.configuration
  database = 'sqlite3::memory:'

  authenticators.reset!
  authenticators do
    sql << {
      :database => 'sqlite3:db/accounts.sqlite3',
      :user_table => 'users',
      :username_column => 'username',
      :password_column => 'password',
      :crypted_password => 'md5'
    }
  end
end
