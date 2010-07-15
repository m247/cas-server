module CASServer
  module Credential
    def self.app(app)
      @app = app
      self
    end

    def self.requestor(&block)
      Requestor.new(&block).call(@app)
    end
    def self.acceptor(&block)
      Acceptor.new(&block).call(@app)
    end

    class Requestor
      def initialize(&blk)
        blk.call(self) if blk
      end
      def login(&blk) # :yield: login_ticket
        @login = blk
      end
      def gateway(&blk) # :yield: redirect_url, warn
        @gateway = blk
      end
      def logged_in(&blk)
        @logged_in = blk
      end
      def call(app)
        @params = app.params
        if show_login_form?(app.logged_in?)
          return @login.call
        else
          if gateway?
            return @gateway.call(params['service'], warn?) unless app.logged_in?

            st = new_service_ticket(app)
            return @gateway.call(st.url, warn?)
          end

          # BEGIN NON-STANDARD FEATURE
          if service? && app.logged_in?
            st = new_service_ticket(app)
            return @gateway.call(st.url, warn?)
          end
          # END NON-STANDARD FEATURE

          return @logged_in.call
        end
      end
      private
        def new_service_ticket(app)
          st = ServiceTicket.new(:service => params['service'],
            :username => app.ticket_granting_cookie.username)
          st.save
          st
        end
        def params
          @params
        end
        def renew?
          params['renew'] == 'true'
        end
        def gateway?
          service? && (params['gateway'] == 'true')
        end
        def service?
          !params['service'].nil? && params['service'] != ''
        end
        def warn?
          params['warn'] && params['warn'] != ''
        end
        def show_login_form?(logged_in)
          return true if renew?
          return false if logged_in
          return false if gateway?

          true
        end
    end

    class Acceptor
      def initialize(&blk)
        blk.call(self) if blk
      end
      def redirect(&blk)
        @redirect = blk
      end
      def success(&blk)
        @success = blk
      end
      def failure(&blk)
        @failure = blk
      end
      def call(app)
        @params = app.params

        acct = if username_password_login? && LoginTicket.valid?(params['lt'])
          params['username'] = params['username'].downcase if CASServer.configuration.lowercase_usernames?
          CASServer.authenticators.detect do |source|
            $LOG.info("Authenticating #{params['username']} with #{source.class}")
            r = source.authenticate(params['username'], params['password'], params['service'], app.request)
            break r unless r.nil?
          end
        else
          CASServer.trust_authenticators.detect do |source|
            $LOG.info("Authenticating request with #{source.class}")
            r = source.authenticate(params['service'], app.request)
            break r unless r.nil?
          end
        end

        return @failure.call('Invalid Credentials') if acct.nil?
        return @failure.call('Account "%s" is locked' % acct.username) if acct.locked?

        app.ticket_granting_cookie = TicketGrantingCookie.new(:username => acct.username,
          :extra => acct.extra)
        app.ticket_granting_cookie.save

        if has_service?
          st = ServiceTicket.new(:username => acct.username, :service => params['service'])
          st.save
          return @redirect.call(st.url, should_warn?)
        end
        return @success.call
      end
      private
        def params
          @params
        end
        def has_service?
          !params['service'].nil? && params['service'] != ''
        end
        def should_warn?
          params['warn'] && params['warn'] != ''
        end
        def username_password_login?
          params['username'] && params['password'] && params['lt']
        end
    end
  end
end
