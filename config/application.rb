require File.expand_path('../boot', __FILE__)

require 'casserver'

CASServer.configuration do
  login_ticket.maximum_lifetime            = 300
  service_ticket.maximum_lifetime          = 300
  ticket_granting_cookie.maximum_lifetime  = 172800

  ssl.ca_file = 'config/cacert.pem'
end

begin
  require File.expand_path("../environments/#{CASServer::Application.environment}", __FILE__)
rescue LoadError
  puts "** No environment file for #{CASServer::Application.environment}, have you configured it?"
end
