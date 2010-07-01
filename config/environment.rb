require File.expand_path('../application', __FILE__)

# Sinatra::Base configuration settings
CASServer::Application.configure do |app|
  app.set :root, File.expand_path('../../', __FILE__)
  app.set :views, File.join(app.root, 'views')
  app.set :translations, File.join(app.root, 'config', 'i18n')
end
