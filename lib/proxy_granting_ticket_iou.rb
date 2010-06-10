# Requirements
#  - Value should not contain any reference to the ProxyGrantingTickets,
#    nor should it be derivable from the value.
#  - Must not be guessable
#  - Begin with the characters PGTIOU-
#  - Be between 64 and 256 characters in length

class ProxyGrantingTicketIou
  include DataMapper::Resource
  include GenericTicket

  def self.prefix
    'PGTIOU-'
  end
end
