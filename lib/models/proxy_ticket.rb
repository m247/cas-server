# Requirements
#  - Valid for the service identifier (URL) specified to /proxy when created
#  - Valid for only one validation attempt.
#  - Tickets expire after a certain period of time, after expiration
#    attempts to validate with a ticket should result in failure.
#  - Must not be guessable, using secure random data. SecureRandom.hex
#  - Tickets must be prefixed with ST- or PT-
#  - Ticket length should be min 32 characters, ideally 256 characters

class ProxyTicket < ServiceTicket
  class << self
    def prefix
      'PT-'
    end
    def valid_prefix?(ticket)
      super(ticket) || superclass.valid_prefix?(ticket)
    end
    def unexpired
      super + superclass.unexpired
    end
    def expired
      super + superclass.expired
    end
  end

  belongs_to :granted_by_ticket, :model => 'ProxyGrantingTicket', :required => false
end
