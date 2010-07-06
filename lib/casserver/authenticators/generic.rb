module CASServer
  module Authenticator
    class Generic
      def authenticate(user, pass, service = nil, request = nil)
        raise NotImplementedError, "validate must be overridden by subclasses"
      end
      protected
        def extra_attrs
          return [] if @options[:extra].nil?
          attrs = @options[:extra].kind_of?(Array) ? @options[:extra] : @options[:extra].split(',')
          attrs.map(&:strip)
        end
        def locked?(record)
          return false unless @options.has_key?(:locked)
          @options[:locked].call(record)
        end
    end
  end
end
