begin
  require 'net/ldap'
rescue LoadError
  $stderr.puts %(
--- Authenticator Dependency ------------------------------
  The LDAP Authenticator requires the 'ruby-net-ldap' gem
  to be installed. Please install it and then restart the
  application.

  gem install ruby-net-ldap
-----------------------------------------------------------)
  exit 1
end

module CASServer
  module Authenticator
    # LDAP Authentication source
    #
    # Example configurations
    # Plain Unencrypted LDAP
    # auth.ldap << {
    #   :host => 'ldap.example.net',
    #   :port => 389,
    #   :base => 'dc=example,dc=net',
    #   :filter => '(objectClass=person)',
    #   :user_attr => 'cn'
    # }
    # Encrypted LDAP
    # auth.ldap << {
    #   :host => 'ldap.example.net',
    #   :port => 389,
    #   :base => 'dc=example,dc=net',
    #   :filter => '(objectClass=person)',
    #   :user_attr => 'cn',
    #   :encryption => :simple_tls
    # }
    class LDAP < Generic
      NET_LDAP_INIT_OPTIONS = [:host, :port, :base, :encryption].freeze

      def self.defaults
        {:port => 389, :filter => '(objectClass=person)', :user_attr => 'cn',
          :user_prefix => nil, :auth_user => nil, :auth_password => nil }
      end

      def initialize(options)
        conn_options, @options = extract_connection_and_options(options)
        @conn = Net::LDAP.new(conn_options)
      end
      def authenticate(user, pass, service = nil, request = nil)
        begin
          bind_with_username(user, pass) do |record|
            Account.new(user) do |extra|
              extra_attrs.each do |attr_name|
                unless record[attr_name].empty?
                  if record[attr_name].length == 1
                    extra[attr_name] = record[attr_name].first
                  else
                    extra[attr_name] = record[attr_name]
                  end
                end
              end
            end
          end
        rescue Net::LDAP::LdapError => e
        
        end
      end
      protected
        def preauth!
          return if @options[:auth_user].nil? && @options[:auth_password].nil?
          raise AuthenticationError, "Preauthentication requires both auth user and password" if [@options[:auth_user], @options[:auth_password]].any? {|a| a.nil? || a == '' }
          @conn.authenticate(@options[:auth_user], @options[:auth_password])
        end
        def bind_with_username(username, password)
          preauth!

          filter = auth_filter(username)
          return false unless @conn.bind_as(:password => password, :filter => filter)

          yield @conn.search(:filter => filter).first
        end
        def auth_filter(username)
          f = Net::LDAP::Filter.eq(@options[:user_attr], @options[:user_prefix] + username)
          unless @options[:filter].nil? || @options[:filter].blank?
            f &= Net::LDAP::Filter.construct(@options[:filter])
          end
          f
        end
        def extract_connection_and_options(options)
          self.class.defaults.merge(options).inject([{}, {}]) do |m, k, v|
            if NET_LDAP_INIT_OPTIONS.include?(k)
              m[0][k] = v
            else
              m[1][k] = v
            end
          end
        end
    end
  end
end
