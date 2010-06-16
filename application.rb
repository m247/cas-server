require 'environment'
require 'sinatra/base'

class CASServer < Sinatra::Base
  configure do
    set :views, "#{File.dirname(__FILE__)}/views"
    set :sessions, true

    SiteConfig = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")

    # load models
    $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
    Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }

    # $adapter://$username:$password@$hostname/$database
    DataMapper.setup(:default, (ENV["DATABASE_URL"] ||
      "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/#{Sinatra::Base.environment}.db"))
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
