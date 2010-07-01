module CASServer
  module Proxy
    def self.app(app)
      @app = app
      self
    end
    def self.grant(&blk)
      Grantor.new(&blk).call(@app)
    end
    class Grantor
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
          raise CASError, 'INVALID_REQUEST' unless valid_request?

          pgt = ProxyGrantingTicket.validate!(params['pgt'])
          raise CASError, 'BAD_PGT' if pgt.nil?

          pt = ProxyTicket.create(:username => pgt.service_ticket.username,
            :service => params['targetService'])
          @success.call(pt.name)
        rescue CASError => e
          @failure.call(e.message)
        rescue Exception
          @failure.call('INTERNAL_ERROR')
        end
      end
      private
        def params
          @params
        end
        def pgt_given?
          params['pgt'] && params['pgt'] != ''
        end
        def target_given?
          params['targetService'] && params['targetService'] != ''
        end
        def valid_request?
          pgt_given? && target_given?
        end
    end
  end
end
