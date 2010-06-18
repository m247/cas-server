module Validate
  def self.app(app)
    @app = app
  end
  def self.plain(&blk)
    Plain.new(&blk).call(@app)
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
end
