module CASServer
  class Account
    attr_reader :username, :extra
    def initialize(username, extra = {})
      @username = username
      @extra = extra

      yield @extra if block_given?
    end

    # Set within the authenticators to true/false
    def locked?
      @extra[:locked]
    end
  end
end
