require File.expand_path('../config/environment', __FILE__)

CASServer::Application.set :run, false
CASServer::Application.set :environment, :production

run CASServer::Application
