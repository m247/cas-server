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
    def database=(options)
      @database = options
    end
    def database
      @database
    end
    def ssl
      @ssl ||= OpenStruct.new
    end

    # Authenticators setup
    def authenticators(&blk)
      @authenticators ||= AuthenticatorConf.new
      @authenticators.instance_eval(&blk) if blk
      @authenticators
    end

    class AuthenticatorConf
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
      def method_missing(meth, *args, &block)
        # lets create the method shall we :D
        instance_eval <<-RUBY
          def #{meth}                       # def foo
            #{meth}_options = [:#{meth}]    #   foo_options = [:foo]
            @set << #{meth}_options         #   @set << foo_options
            #{meth}_options                 #   foo_options
          end                               # end
        RUBY

        # Now we call our new method, whether its the setter or the getter
        __send__(meth, *args)
      end
    end
  end
end
