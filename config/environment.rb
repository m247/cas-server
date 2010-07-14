require File.expand_path('../application', __FILE__)

# Sinatra::Base configuration settings
CASServer::Application.configure do |app|
  app.set :root, File.expand_path('../../', __FILE__)
  app.set :views, File.join(app.root, 'views')
  app.set :public, File.join(app.root, 'public')
  app.set :translations, File.join(app.root, 'config', 'i18n')

  LOGGER = Logger.new(File.join(app.root, "sinatra.log"))
end
