unless defined?(Bundler)
  require 'rubygems'
  require 'bundler'
  Bundler.setup
end

require 'dm-core'
require 'dm-types'
require 'dm-timestamps'
require 'dm-migrations'
require 'dm-validations'
require 'dm-aggregates'
require 'yajl/json_gem'
require 'haml'
require 'ostruct'

require 'sinatra' unless defined?(Sinatra)

configure do
  SiteConfig = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")

  # load models
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }

  # $adapter://$username:$password@$hostname/$database
  DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/#{Sinatra::Base.environment}.db"))
end
