CASServer.configuration do
  database = 'sqlite3::memory:'

  authenticators.reset!
  authenticators do
    testing << {
      :users => ['test:testing']
    }
  end
end
