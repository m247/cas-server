module CASServer
  module Authenticator
    autoload :ActiveDirectory,  "lib/authenticators/active_directory.rb"
    autoload :Generic,          "lib/authenticators/generic.rb"
    autoload :LDAP,             "lib/authenticators/ldap.rb"
    autoload :SQL,              "lib/authenticators/sql.rb"

    class Group
      include Enumerable
      def initialize(configuration)
        @authenticators = configuration.map do |type, options|
          authenticator_klass(type).new(options)
        end
      end
      def each
        @authenticators.each do |klass|
          yield klass
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
