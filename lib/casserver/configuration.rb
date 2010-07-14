require 'ostruct'

module CASServer
  class Configuration
    def initialize(&blk)
      instance_eval(&blk) if blk
    end

    # Quick Proxy methods, these allow easier writing of class accessors
    def login_ticket
      LoginTicket
    end
    def service_ticket
      ServiceTicket
    end
    def ticket_granting_cookie
      TicketGrantingCookie
    end

    # Database configuration, injects the DataMapper setup
    # into the Main application configure block
    def database(options = nil)
      unless options.nil?
        @database = options
        ::DataMapper.setup(:default, @database)
      end
      @database
    end
    def ssl
      @ssl ||= OpenStruct.new
    end
    def use_lowercase_usernames(opt = true)
      @lowercase_usernames = !! opt     # Force boolean
    end
    def lowercase_usernames?
      @lowercase_usernames || false
    end

    # Authenticators setup
    def authenticators(&blk)
      @authenticators ||= AuthenticatorConf.new
      @authenticators.instance_eval(&blk) if blk
      @authenticators
    end

    class AuthenticatorConf
      instance_methods.each { |m| undef_method(m.to_sym) unless %w(
          __send__ __id__ send class inspect instance_eval
          instance_variables ).include?(m.to_s) }

      attr_reader :set
      def initialize
        reset!
      end
      def all
        @set
      end
      def get(group)
        @set.select { |g, opts| g == group }.map(&:last)
      end
      def reset!
        @set = []
      end
      def method_missing(meth, *args)
        self.class.send(:define_method, meth.to_sym) do
          @set << [meth.to_sym]
          @set.last
        end

        __send__(meth, *args)
      end
    end
  end
end
