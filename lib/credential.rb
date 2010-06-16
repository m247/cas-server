module Credential
  def self.app(app)
    @app = app
  end

  def self.requestor(&block)
    Requestor.new(&block).call(@app)
  end

  class Requestor
    def initialize(&blk)
      instance_eval(&blk) if blk
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
        return @login.call(LoginTicket.create)
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
end
