module Validate
  def self.app(app)
    @app = app
  end
  def self.plain(&blk)
    Plain.new(&blk).call(@app)
  end
  def self.service(&blk)
    Service.new(&blk).call(@app)
  end
  def self.proxy(&blk)
    Proxy.new(&blk).call(@app)
  end

  class Plain
    def initialize(&blk)
      instance_eval(&blk) if blk
    end

    def success(&blk)
      @success = blk
    end
    def failure(&blk)
      @failure = blk
    end

    def call(app)
      @params = app.params
      begin
        st = ServiceTicket.validate!(app.params['ticket'], app.params['service'], renew?)
        @success.call(st.username)
      rescue
        @failure.call
      end
    end
    private
      def renew?
        @params['renew'] == 'true'
      end
  end
  class Service
    def initialize(&blk)
      instance_eval(&blk) if blk
    end
    def success(&blk)
      @success = blk
    end
    def failure(&blk)
      @failure = blk
    end
    def call(app)
      @params = app.params
      begin
        t = ticket_klass.validate!(app.params['ticket'], app.params['service'], renew?)

        verify_proxy_callback(t) do |pgt, res|
          if %w(200 202 301 302 304).include?(res.code)
            pgt.save
          end
        end

        @success.call(t.username, t.proxy_granting_ticket)
      rescue Exception => e
        @failure.call(e.message)
      end
    end
    protected
      def ticket_klass
        ServiceTicket
      end
      def params
        @params
      end
      def renew?
        params['renew'] == 'true'
      end
      # TODO: Check the code down here
      def proxy_granting_ticket(service_ticket)
        ProxyGrantingTicket.new(:service_ticket => service_ticket,
          :iou => ProxyGrantingTicketIOU.new)
      end
      def proxy_callback?
        params['pgtUrl'] && params['pgtUrl'] =~ %r{^https://}
      end
      def verify_proxy_callback(service_ticket)
        return unless proxy_callback?
        begin
          pgt = proxy_granting_ticket(service_ticket)
          uri = URI.parse(params['pgtUrl'])
          https = Net::HTTP.new(uri.host, uri.port)
          https.use_ssl = true
          https.ca_file = options.ca_file
          https.verify_mode = OpenSSL::SSL::VERIFY_PEER
          https.start do
            uri.query = uri.query ? uri.query + "&#{pgt.to_query_string}" : pgt.to_query_string
            https.request_get(uri.request_uri) do |res|
              yield pgt, res
            end
          end
        rescue OpenSSL::SSL::SSLError
          return
        end
      end
  end
  class Proxy < Service
    protected
      def ticket_klass
        ProxyTicket
      end
  end
end
