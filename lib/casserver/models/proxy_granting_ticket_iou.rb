# Requirements
#  - Value should not contain any reference to the ProxyGrantingTickets,
#    nor should it be derivable from the value.
#  - Must not be guessable
#  - Begin with the characters PGTIOU-
#  - Be between 64 and 256 characters in length

module CASServer
  class ProxyGrantingTicketIou
    include DataMapper::Resource
    include GenericTicket

    def self.prefix
      'PGTIOU-'
    end

    # Required is false as otherwise the ProxyGrantingTicket after :save fails
    belongs_to :proxy_granting_ticket, :required => false
  end
end
