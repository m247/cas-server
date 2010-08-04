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

          do_success(t)
        rescue CASError => e
          @failure.call(e.message)
        rescue Exception => e
          $LOG.warn("#{self.class}: #{e.message}\n#{e.backtrace.join("\n")}")
          @failure.call('INTERNAL_ERROR')
        end
      end
      protected
        def ticket_klass
          ServiceTicket
        end
        def do_success(t)
          pgt_iou = t.proxy_granting_ticket.proxy_granting_ticket_iou rescue nil
          @success.call(t.username, pgt_iou, t.granted_by_cookie.extra)
        end
        def params
          @params
        end
        def renew?
          params['renew'] == 'true'
        end
        def proxy_granting_ticket(ticket, proxy)
          pgt = ProxyGrantingTicket.new(:proxy => proxy)
          pgt.service_ticket = ticket
          pgt.save
          pgt
        end
        def proxy_callback?
          params['pgtUrl'] && params['pgtUrl'] =~ %r{^https://}
        end
        def verify_proxy_callback(ticket, ca_file, &blk)
          return unless proxy_callback?

          pgt = proxy_granting_ticket(ticket, params['pgtUrl'])
          uri = URI.parse(pgt.proxy)
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
        def do_success(t)
          pgt_iou = t.proxy_granting_ticket.proxy_granting_ticket_iou rescue nil
          pgt_proxy = t.granted_by_ticket.proxy rescue nil
          @success.call(t.username, pgt_iou, t.granted_by_cookie.extra, Array(pgt_proxy))
        end
    end
  end
end
