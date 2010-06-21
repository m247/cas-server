# Requires
# Used by services to obtain multiple proxy tickets
#  - Not one time use
#  - Must be destroyed when the related login is
#  - Must not be guessable
#  - Must begin with PGT-
#  - At least 64 characters, ideally 256

class ProxyGrantingTicket
  include DataMapper::Resource
  include GenericTicket

  def self.prefix
    'PGT-'
  end

  has 1, :proxy_granting_ticket_iou

  after :save, :create_proxy_granting_ticket_iou
  def create_proxy_granting_ticket_iou
    self.proxy_granting_ticket_iou = ProxyGrantingTicketIou.create
  end
end
