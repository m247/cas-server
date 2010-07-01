module CASServer
  class TicketGrantingCookie
    include DataMapper::Resource

    include GenericTicket
    include ExpiringTicket

    def self.prefix
      'TGC-'
    end
    def self.valid?(ticket)
      valid_prefix?(ticket) && unexpired.first(:name => ticket)
    end

    property :username, String, :required => true
    property :extra, Json, :lazy => true

    has n, :granted_tickets, :model => 'ServiceTicket', :child_key => ['granted_by_cookie_name']
  end
end
