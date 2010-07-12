# Generated by cucumber-sinatra. (Thu Jun 10 15:28:31 +0100 2010)
ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)

require 'sinatra'
require 'capybara'
require 'capybara/cucumber'
require 'spec'
require 'webmock'

# set test environment
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

require File.expand_path('../../../config/environment', __FILE__)

# establish in-memory database for testing
DataMapper.setup(:default, "sqlite3::memory:")
# DataMapper.auto_migrate!.each do |klass|
#   klass.raise_on_save_failure = true
# end

Before do
  WebMock.disable_net_connect!
  WebMock.reset_webmock
  DataMapper.auto_migrate!.each do |klass|
    klass.raise_on_save_failure = true
  end

  # Begin cludge to help us test redirects with capybara
  CASServer::Application.get '/redirection' do
    [request.request_method, request.url].join(" ")
  end
  CASServer::Application.post '/redirection' do
    [request.request_method, request.url].join(" ")
  end
end

World do
  Capybara.app = CASServer::Application
  include Capybara
  include Spec::Expectations
  include Spec::Matchers
  include WebMock
end
