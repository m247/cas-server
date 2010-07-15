module CASServer
  module Authenticator
    class ActiveDirectory < LDAP
      def self.defaults
        # Locked checks to see if ACCOUNTDISABLE flag is set on userAccountControl attribute
        superclass.defaults.merge({:user_attr => 'sAMAccountName',
          :locked => proc { |r| r['userAccountControl'][0].to_i & 0x002 == 0x002 }})
      end
    end
  end
end
