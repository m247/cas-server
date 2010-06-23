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
        return @login.call(LoginTicket.create)  # BUG: Called in the scope of this class, not the Sinatra action
      else
        if gateway?
          return @gateway.call(service_ticket.url, warn?) if app.logged_in? # TODO: Fix service_ticket.url
          return @gateway.call(params['service'], warn?)
        end
        return @logged_in.call
      end
    end
    private
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
        params['warn'] == '1'
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
        app.authenticators.detect do |source|
          r = source.authenticate(params['username'], params['password'], params['service'], app.request)
          break r unless r.nil?
        end
      else
        app.trust_authenticators.detect do |source|
          r = source.authenticate(params['service'], app.request)
          break r unless r.nil?
        end
      end

      return @failure.call('Invalid Credentials') if acct.nil?
      return @failure.call('Account "%s" is locked' % acct.username) if acct.locked?

      app.ticket_granting_cookie = TicketGrantingCookie.create(:username => acct.username,
        :extra => acct.extra)

      if has_service?
        st = ServiceTicket.create(:username => acct.username, :service => params['service'])
        return @redirect.call(st.url, should_warn?)
      end
      return @success.call
    end
    private
      def params
        @params
      end
      def has_service?
        !@params['service'].nil? && @params['service'] != ''
      end
      def should_warn?
        @params['warn'] == '1'
      end
      def username_password_login?
        @params['username'] && @params['password'] && @params['lt']
      end
  end
end
