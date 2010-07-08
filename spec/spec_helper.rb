require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)

require 'sinatra'
require 'spec'
require 'spec/interop/test'
require 'rack/test'

# set test environment
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

require File.expand_path('../../config/environment', __FILE__)

# establish in-memory database for testing
DataMapper.setup(:default, "sqlite3::memory:")

# Require our shared specs so we can run specs individually
require File.expand_path('../generic_ticket_spec', __FILE__)
require File.expand_path('../expiring_ticket_spec', __FILE__)

Spec::Runner.configure do |config|
  # reset database before each example is run
  config.before(:each) do
    DataMapper.auto_migrate!.each do |klass|
      klass.raise_on_save_failure = true
    end
  end
end
