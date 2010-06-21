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

  belongs_to :service_ticket, :required => false
  has 1, :proxy_granting_ticket_iou
  has n, :granted_proxy_tickets, :model => 'ProxyTicket', :child_key => ['granted_by_ticket_name']

  after :save,      :create_iou
  before :destroy!, :destroy_iou

  private
    def create_iou
      self.proxy_granting_ticket_iou = ProxyGrantingTicketIou.create
    end
    def destroy_iou
      self.proxy_granting_ticket_iou.destroy!
    end
end
