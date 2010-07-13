require 'securerandom'

module CASServer
  module GenericTicket
    TICKET_LENGTH = 64  # Min 64, Max 256
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
      base.instance_eval do
        property :name, String, :length => GenericTicket::TICKET_LENGTH, :key => true,
          :default => lambda { |r,p| r.class.generate }, :writer => :private
        property :created_at, Time, :writer => :private,
          :default => lambda { |r,p| Time.now.utc }
      end
    end

    module ClassMethods
      def prefix
        ''
      end

      def valid_prefix?(ticket)
        ticket.slice(0, prefix.length) == prefix
      end

      def generate
        extra = ''
        byte_count = (TICKET_LENGTH / 2) - (prefix.length / 2.0).ceil
        difference = TICKET_LENGTH - prefix.length - (byte_count * 2)
        difference.times { extra << (rand(26) + ?a).chr }

        prefix + extra + SecureRandom.hex(byte_count)
      end
    end

    module InstanceMethods
      def to_s
        name
      end
    end
  end
end
