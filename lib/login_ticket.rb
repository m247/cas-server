# Requirements
#  - Must be probablistically unique
#  - Valid for one authentication attempt
#  - Begin with LT-

class LoginTicket
  include DataMapper::Resource

  include GenericTicket
  include ExpiringTicket

  def self.prefix
    'LT-'
  end

  def self.valid?(ticket)
    return false unless valid_prefix?(ticket)

    lt = unexpired.first(:name => ticket)
    lt && lt.expire!
  end
end
