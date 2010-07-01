# Base dependencies
require 'dm-core'
require 'dm-types'
require 'dm-timestamps'
require 'dm-migrations'
require 'dm-validations'
require 'dm-aggregates'
require 'yajl/json_gem'

module CASServer
  autoload :Application,            "lib/casserver/application.rb"

  autoload :Authenticator,          "lib/casserver/authenticators.rb"
  autoload :Authenticators,         "lib/casserver/authenticators.rb"
  autoload :CASError,               "lib/casserver/cas_error.rb"

  autoload :Configuration,          "lib/casserver/configuration.rb"

  # Handlers
  autoload :Credential,             "lib/casserver/handlers/credential.rb"
  autoload :Proxy,                  "lib/casserver/handlers/proxy.rb"
  autoload :Validate,               "lib/casserver/handlers/validate.rb"

  # Models
  autoload :ExpiringTicket,         "lib/casserver/models/expiring_ticket.rb"
  autoload :GenericTicket,          "lib/casserver/models/generic_ticket.rb"
  autoload :LoginTicket,            "lib/casserver/models/login_ticket.rb"
  autoload :ProxyGrantingTicket,    "lib/casserver/models/proxy_granting_ticket.rb"
  autoload :ProxyGrantingTicketIou, "lib/casserver/models/proxy_granting_ticket_iou.rb"
  autoload :ProxyTicket,            "lib/casserver/models/proxy_ticket.rb"
  autoload :ServiceTicket,          "lib/casserver/models/service_ticket.rb"
  autoload :TicketGrantingCookie,   "lib/casserver/models/ticket_granting_cookie.rb"

  def self.configuration(&blk)
    @configuration ||= Configuration.new
    @configuration.instance_eval(&blk) if blk
    @configuration
  end
  def self.authenticators
    @authenticators ||= Authenticator::Group.new(configuration.authenticators)
  end
end

# Core extensions
class String
  def camelize
    self.gsub(/(?:^(.)|_(.))/) { |m| ($1 || $2).upcase }
  end unless defined?(camelize)
end
