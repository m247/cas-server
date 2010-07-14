require 'sinatra/base'
require 'sinatra/r18n'
require 'builder'
require 'haml'
require 'sass'

module CASServer
  class Application < Sinatra::Base
    register Sinatra::R18n

    configure do
      set :sessions, true
      set :haml, :format => :html5
      set :environment, (ENV['RACK_ENV'] || :development)
    end

    error do
      e = request.env['sinatra.error']
      Kernel.puts e.backtrace.join("\n")
      'Application Error'
    end

    helpers do
      def logger
        LOGGER
      end
      def logged_in?
        ticket_granting_cookie && !ticket_granting_cookie.expired?
      end
      def ticket_granting_cookie=(tgc)
        @ticket_granting_cookie = tgc

        return response.delete_cookie('tgt') if tgc.nil?

        response.set_cookie('tgt', :value => tgc.name,
          :path => '/', #request.env['REQUEST_PATH'],
          :domain => request.env['SERVER_NAME'],
          :secure => request.env['HTTPS'] == 'on', :expires => tgc.expires_at)
      end
      def ticket_granting_cookie
        @ticket_granting_cookie ||=
          TicketGrantingCookie.get(request.cookies['tgt'])
      end
      def login_ticket
        LoginTicket.create
      end
      def current_user
        ticket_granting_cookie.username
      end
      def text(str)
        content_type 'text/plain', :charset => 'utf-8'
        str
      end
    end

    before do
      headers({
        'Pragma'        => 'no-cache',
        'Cache-Control' => 'no-store',
        'Expires'       => Time.at(0).utc.rfc2822 })
      Credential.app self
      Validate.app self
      Proxy.app self
    end

    get '/' do
      redirect '/login'
    end
    get '/css/:stylesheet.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass params[:stylesheet].to_sym
    end

    get '/login' do
      Credential.requestor do |r|
        r.gateway do |url, warn|
          if warn
            haml :redirect, :locals => {:target => url}
          else
            redirect(url, 303)
          end
        end
        r.login { haml :login_form }
        r.logged_in do
          haml :login_form, :locals => {:message => t.login.success(current_user)}
        end
      end
    end

    post '/login' do
      Credential.acceptor do |a|
        a.redirect do |url, warn|
          warn ? haml(:redirect, :locals => {:target => url, :message => t.login.redirect}) :
            redirect(url, 303)
        end
        a.failure { |reason| haml :login_form, :locals => {:message => reason} }
        a.success do
          haml :login_form, :locals => {:message => t.login.success(current_user)}
        end
      end
    end

    get '/logout' do
      ticket_granting_cookie = nil
      @url = params[:url] if params[:url] =~ /^https?:\/\//
      haml :logged_out
    end

    get '/validate' do
      Validate.plain do |p|
        p.success { |username| text "yes\n#{username}\n" }
        p.failure { text "no\n\n" }
      end
    end

    get '/serviceValidate' do
      content_type 'application/xml', :charset => 'utf-8'
      Validate.service do |s|
        s.success do |username, pgtiou|
          builder do |xml|
            xml.cas :serviceResponse, 'xmlns:cas' => 'http://www.yale.edu/tp/cas' do
              xml.cas :authenticationSuccess do
                xml.cas :user, username
                if pgtiou
                  xml.cas :proxyGrantingTicket, pgtiou
                end
              end
            end
          end
        end
        s.failure do |code|
          builder do |xml|
            xml.cas :serviceResponse, 'xmlns:cas' => 'http://www.yale.edu/tp/cas' do
              reason = t.error.send(code.downcase, params['ticket'], params['service'])
              xml.cas :authenticationFailure, reason, :code => code
            end
          end
        end
      end
    end

    get '/proxyValidate' do
      content_type 'application/xml', :charset => 'utf-8'
      Validate.proxy do |p|
        p.success do |username, pgtiou, proxies|
          builder do |xml|
            xml.cas :serviceResponse, 'xmlns:cas' => 'http://www.yale.edu/tp/cas' do
              xml.cas :authenticationSuccess do
                xml.cas :user, username
                if pgtiou
                  xml.cas :proxyGrantingTicket, pgtiou
                end
                unless proxies.empty?
                  xml.cas :proxies do
                    proxies.each do |proxy|
                      xml.cas :proxy, proxy
                    end
                  end
                end
              end
            end
          end
        end
        p.failure do |code|
          builder do |xml|
            xml.cas :serviceResponse, 'xmlns:cas' => 'http://www.yale.edu/tp/cas' do
              reason = t.error.send(code.downcase, params['ticket'], params['service'])
              xml.cas :authenticationFailure, reason, :code => code
            end
          end
        end
      end
    end

    get '/proxy' do
      content_type 'application/xml', :charset => 'utf-8'
      Proxy.grant do |g|
        g.success do |pgt|
          builder do |xml|
            xml.cas :serviceResponse, 'xmlns:cas' => 'http://www.yale.edu/tp/cas' do
              xml.cas :proxySuccess do
                xml.cas :proxyTicket, pgt
              end
            end
          end
        end
        g.failure do |code|
          builder do |xml|
            xml.cas :serviceResponse, 'xmlns:cas' => 'http://www.yale.edu/tp/cas' do
              reason = t.error.send(code.downcase, params['ticket'], params['service'])
              xml.cas :proxyFailure, reason, :code => code
            end
          end
        end
      end
    end
  end
end
