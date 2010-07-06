module CASServer
  module Authenticator
    class Testing < Generic
      def initialize(options)
        @users = {}
        @locks = []

        options[:users].each do |user|
          add(*user.split(":", 2))
        end
      end
      def authenticate(user, pass, service = nil, request = nil)
        if @users[user] == pass
          Account.new(user) do |extra|
            extra[:locked] = locked?(user)
          end
        end
      end
      def add(user, pass)
        @users[user] = pass
      end
      def lock!(user)
        @locks << user
      end
      def unlock!(user)
        @locks.delete(user)
      end
      def locked?(user)
        @locks.include?(user)
      end
    end
  end
end
