module CASServer
  module Authenticator
    autoload :ActiveDirectory,  "lib/casserver/authenticators/active_directory.rb"
    autoload :Generic,          "lib/casserver/authenticators/generic.rb"
    autoload :LDAP,             "lib/casserver/authenticators/ldap.rb"
    autoload :SQL,              "lib/casserver/authenticators/sql.rb"
    autoload :Testing,          "lib/casserver/authenticators/testing.rb"

    class Group
      include Enumerable

      def initialize(configuration)
        @authenticators = configuration.map do |type, options|
          authenticator_klass(type).new(options)
        end
      end
      def each
        @authenticators.each do |source|
          yield source
        end
      end

      protected
        def authenticator_klass(type)
          case type
          when :ldap
            Authenticator::LDAP
          when :sql
            Authenticator::SQL
          else
            Authenticator::const_get(type.to_s.camelize)
          end
        end
    end
  end
end
