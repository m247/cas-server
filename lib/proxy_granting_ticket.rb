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
  
end
