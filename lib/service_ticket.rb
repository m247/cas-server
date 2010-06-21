# Requirements
#  - Valid for the service identifier (URL) for which they are generated
#  - Once a validation has been attempted the ticket should be invalidated
#  - Tickets expire after a certain period of time, after expiration
#    attempts to validate with a ticket should result in failure.
#  - Must not be guessable, using secure random data. SecureRandom.hex
#  - Tickets must be prefixed with ST-
#  - Ticket length should be min 32 characters, ideally 256 characters

class ServiceTicket
  include DataMapper::Resource

  include GenericTicket
  include ExpiringTicket

  class << self
    def prefix
      'ST-'
    end
    def sanitize_service_url(service)
      %w(gateway renew service ticket).inject(service) do |str, field|
        str.gsub(/&?#{field}=[^&]*/, '')
      end.gsub(/[\?&]$/, '').gsub(/\/$/, '').gsub('?&', '?').gsub(' ', '+')
    end
    def validate!(ticket, service, renew) # TODO: Handle 'renew' case
      raise 'INVALID_REQUEST' unless ticket && ticket != ''
      raise 'INVALID_TICKET' unless valid_prefix?(ticket)

      st = unexpired.first(:name => ticket)
      raise 'INVALID_TICKET' if st.nil?

      st.expire!

      raise 'INVALID_SERVICE' unless st.service_matches?(service)

      st
    end
  end

  property :type, Discriminator
  property :service, String, :length => 255, :required => true
  property :username, String, :length => 255, :required => true

  has 1, :proxy_granting_ticket
  belongs_to :granted_by_cookie, :model => 'TicketGrantingCookie', :required => false

  def service=(v)
    attribute_set(:service, self.class.sanitize_service_url(v))
  end
  def service_matches?(s)
    self.class.sanitize_service_url(s) == service
  end
  def url
    [service, url_param].join(url_joiner)
  end
  def granted_by_cookie?
    ! self.granted_by_cookie.nil?
  end
  def granted_by_credentials?
    ! granted_by_cookie?
  end
  protected
    def url_param
      'ticket=' + to_s
    end
    def url_joiner
      service.index('?') ? '&' : '?'
    end
end
