module CASServer
  module ExpiringTicket
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
      base.instance_eval do
        property :expires_at, Time, :writer => :private,
          :default => lambda {|r,p| Time.now.utc + r.class.maximum_lifetime }
      end
    end

    module ClassMethods
      def maximum_lifetime=(v)
        @maximum_lifetime = v
      end
      def maximum_lifetime
        @maximum_lifetime ||= 300 # 5 minutes
      end
      def expired
        all(:expires_at.lte => Time.now.utc)
      end
      def unexpired
        all(:expires_at.gt => Time.now.utc)
      end
    end

    module InstanceMethods
      def expire!
        attribute_set(:expires_at, Time.now.utc)
        save!
      end
      def expired?
        expires_at <= Time.now.utc
      end
    end
  end
end
