module CASServer
  module Authenticator
    class SQL < Generic
      CRYPTORS = [:plain, :md5, :sha1, :sha512]
      def self.defaults
        { :users_table => 'users', :username_column => 'username',
          :password_column => 'password', :crypted_password => :md5 }
      end
      def self.next_repository_name
        @@repository_count = (@@repository_count || 0) + 1
        :"cas_auth_sql_#{@@repository_count}"
      end
      def initialize(options)
        options = self.class.defaults.merge(options)
        db_opts = options.delete(:database)
        # db_opts[:user] = db_opts.delete(:username)

        raise ArgumentError, "invalid table name" if options[:users_table].index(/;'\./)

        repo_name = self.class.next_repository_name
        DataMapper.setup(repo_name, db_opts)

        @db = DataMapper.repository(repo_name).adapter
        @sql = 'SELECT * FROM %s WHERE %s = ? AND %s = ?' % [
          options[:users_table], options[:username_column], options[:password_column]]

        @options = options
        require_cryptor!
      end

      def authenticate(user, pass, service = nil, request = nil)
        results = @db.select(@sql, user, crypted_password(pass))

        return false if results.length != 1
        record = results.first

        Account.new(user) do |extra|
          extra_attrs.each do |attr_name|
            extra[attr_name] = record.send(attr_name.to_sym)
          end
        end
      end

      protected
        def crypted_password(pass)
          case @options[:crypted_password].to_sym
          when :plain
            pass
          when :md5
            Digest::MD5.hexdigest(pass)
          when :sha1
            Digest::SHA1.hexdigest(pass)
          when :sha512
            Digest::SHA512.hexdigest(pass)
          end
        end
        def require_cryptor!
          raise "Invalid Password Crypt Algorithm" unless CRYPTORS.include?(@options[:crypted_password])
          begin
            case @options[:crypted_password].to_sym
            when :plain
              return
            else
              require "digest/#{@options[:crypted_password]}"
            end
          rescue LoadError
            $stderr.puts %(Unable to load #{@options[:crypted_password]} cryptor, reverting to plain)
            @options[:crypted_password] = :plain
          end
        end
    end
  end
end
