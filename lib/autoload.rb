autoload :CASError,               "lib/cas_error.rb"

# Handlers
autoload :Credential,             "lib/handlers/credential.rb"
autoload :Proxy,                  "lib/handlers/proxy.rb"
autoload :Validate,               "lib/handlers/validate.rb"

# Models
autoload :ExpiringTicket,         "lib/models/expiring_ticket.rb"
autoload :GenericTicket,          "lib/models/generic_ticket.rb"
autoload :LoginTicket,            "lib/models/login_ticket.rb"
autoload :ProxyGrantingTicket,    "lib/models/proxy_granting_ticket.rb"
autoload :ProxyGrantingTicketIou, "lib/models/proxy_granting_ticket_iou.rb"
autoload :ProxyTicket,            "lib/models/proxy_ticket.rb"
autoload :ServiceTicket,          "lib/models/service_ticket.rb"
autoload :TicketGrantingCookie,   "lib/models/ticket_granting_cookie.rb"
