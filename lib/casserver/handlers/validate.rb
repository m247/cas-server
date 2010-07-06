require 'cgi'

module CASServer
  module Validate
    def self.app(app)
      @app = app
      self
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
        blk.call(self) if blk
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
        blk.call(self) if blk
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

          verify_proxy_callback(t, CASServer.configuration.ssl.ca_file) do |res|
            %w(200 202 301 302 304).include?(res.code)
          end

          @success.call(t.username, t.proxy_granting_ticket && t.proxy_granting_ticket.proxy_granting_ticket_iou)
        rescue CASError => e
          @failure.call(e.message)
        rescue Exception
          @failure.call('INTERNAL_ERROR')
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
        def proxy_granting_ticket(service_ticket)
          service_ticket.proxy_granting_ticket = ProxyGrantingTicket.create
        end
        def proxy_callback?
          params['pgtUrl'] && params['pgtUrl'] =~ %r{^https://}
        end
        def verify_proxy_callback(service_ticket, ca_file, &blk)
          return unless proxy_callback?

          pgt = proxy_granting_ticket(service_ticket)
          uri = URI.parse(params['pgtUrl'])
          https = Net::HTTP.new(uri.host, uri.port)
          https.use_ssl = true
          https.ca_file = ca_file
          https.verify_mode = OpenSSL::SSL::VERIFY_PEER

          pgt_query_string = 'pgtId=%s&pgtIou=%s' % [ CGI.escape(pgt.name),
            CGI.escape(pgt.proxy_granting_ticket_iou.name) ]
          uri.query = uri.query ? (uri.query + '&' + pgt_query_string) : pgt_query_string

          begin
            https.start do
              https.request_get(uri.request_uri) do |res|
                unless blk.call(res)
                  pgt.destroy!
                end
              end
            end
          rescue OpenSSL::SSL::SSLError
            pgt.destroy!
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
end
