module CASServer
  module Authenticator
    class ActiveDirectory < LDAP
      def self.defaults
        superclass.defaults.merge({:user_attr => 'sAMAccountName'})
      end
    end
  end
end
