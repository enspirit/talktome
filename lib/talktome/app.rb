require 'sinatra'
require 'finitio'
require 'rack/robustness'
module Talktome
  class App < Sinatra::Application

    use Rack::Robustness do |g|
      g.catch_all
      g.status 500
      g.content_type 'text/plain'
      g.body{ "An error occured." }
    end

    set :raise_errors, true
    set :show_exceptions, false
    set :talktome, Talktome::Client::Local.new(ROOT_FOLDER/'templates')

    VALIDATION_SCHEMA = ::Finitio.system(<<~FIO)
      @import finitio/data
      Email = String(s | s =~ /^[^@]+@[^@]+$/ )
      {
        to       :? Email
        reply_to :? Email
        ...      :  .Object
      }
    FIO

    post %r{/([a-z-]+([\/][a-z-]+)*)/} do |action, _|
      begin
        as_array = info.map{|k,v| {'key' => k.capitalize, 'value' => v}}
        subject  = Talktome.env('TALKTOME_EMAIL_SUBJECT', 'Someone wants to reach you!')
        footer   = Talktome.env('TALKTOME_EMAIL_FOOTER', "Truly yours,\n
          Sent by [Enspirit.be](https://enspirit.be/), contact us if you need help with any IT task.")
        user     = load_user_from_info!
        settings.talktome.talktome(action, user, info.merge(allvars: as_array, subject: subject, footer: footer), [:email]){|email|
          email.reply_to = info[:reply_to] if info.has_key?(:reply_to)
        }
        [ 200, { "Content-Type" => "text/plain"}, ["Ok"] ]
      rescue JSON::ParserError
        fail!("Invalid data")
      rescue Finitio::Error => ex
        fail!(ex.message)
      rescue ::Talktome::InvalidEmailError
        fail!("Invalid email address")
      rescue ::Talktome::TemplateNotFoundError
        fail!("No such template", 404)
      end
    end

  private

    def info
      @info ||= VALIDATION_SCHEMA.dress(JSON.parse(request.body.read)).tap{|info|
        not_a_robot!(info)
      }
    end

    def load_user_from_info!
      if to = info[:to]
        secret = Talktome.env('TALKTOME_BEARER_SECRET')
        fail!("Missing secret", 400) unless secret
        fail!("Invalid secret", 401) unless "Bearer #{secret}" == env["HTTP_AUTHORIZATION"]
        { email: info[:to] }
      else
        {}
      end
    end

    def fail!(message, status = 400)
      halt([ status, { "Content-Type" => "text/plain"}, [message] ])
    end

    def not_a_robot!(info)
      # `reply_to_confirm` is a honeypot field, if it's filled it means it's a bot and an error is thrown
      raise ::Talktome::InvalidEmailError if info[:reply_to_confirm] && info[:reply_to_confirm] =~ /^[^@]+@[^@]+$/
    end

  end # class App
end # module Talktome
