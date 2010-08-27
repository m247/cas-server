module CASServer
  module Authenticator
    class Generic
      def authenticate(user, pass, service = nil, request = nil)
        raise NotImplementedError, "validate must be overridden by subclasses"
      end
      protected
        def extra_attrs
          return [] if @options[:extra_attributes].nil?
          attrs = @options[:extra_attributes].kind_of?(Array) ?
            @options[:extra_attributes] : @options[:extra_attributes].split(',')
          attrs.map(&:strip)
        end
        def merge_fixed_attrs(extras)
          return extras if @options[:fixed_attributes].nil?
          @options[:fixed_attributes].merge(extras)
        end
        def locked?(record)
          return false unless @options.has_key?(:locked)
          @options[:locked].call(record) rescue true  # Fail safe, if there is a locked proc and it
                                                      # errors, don't let them in. Should be logged.
        end
    end
  end
end
