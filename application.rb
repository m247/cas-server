require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra/base'
require 'environment'

class CASServer < Sinatra::Base
  configure do
    set :views, "#{File.dirname(__FILE__)}/views"
    set :sessions, true
  end

  error do
    e = request.env['sinatra.error']
    Kernel.puts e.backtrace.join("\n")
    'Application Error'
  end

  helpers do

  end

  get '/' do
    haml :root
  end

  get '/login' do

  end

  post '/login' do

  end

  get '/logout' do
    @url = params[:url] if params[:url] =~ /^https?:\/\//
    haml :logged_out
  end

  get '/validate' do

  end

  get '/serviceValidate' do

  end

  get '/proxyValidate' do

  end

  get '/proxy' do

  end
end
