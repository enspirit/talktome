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

    VALIDATION_SCHEMA = ::Finitio.system(<<~FIO)
      @import finitio/data
      Email = String(s | s =~ /^[^@]+@[^@]+$/ )
      {
        reply_to :? Email
        ...      :  .Object
      }
    FIO

    TALKTOME = Talktome::Client::Local.new(ROOT_FOLDER/'templates')

    post %r{/([a-z-]+)/} do |action|
      begin
        as_array = info.map{|k,v| {'key' => k.capitalize, 'value' => v}}
        subject  = Talktome.env('TALKTOME_EMAIL_SUBJECT', 'Someone wants to reach you!')
        footer   = Talktome.env('TALKTOME_EMAIL_FOOTER', "Truly yours,\n
          Sent by [Enspirit.be](https://enspirit.be/), contact us if you need help with any IT task.")
        TALKTOME.talktome(action, {}, info.merge(allvars: as_array, subject: subject, footer: footer), [:email]){|email|
          email.reply_to = info[:reply_to] if info.has_key?(:reply_to)
        }
        [ 200, { "Content-Type" => "text/plain"}, ["Ok"] ]
      rescue JSON::ParserError
        fail!("Invalid data")
      rescue Finitio::Error => ex
        fail!(ex.message)
      rescue ::Talktome::InvalidEmailError => ex
        fail!("Invalid email address")
      end
    end

  private

    def info
      @info ||= VALIDATION_SCHEMA.dress(JSON.parse(request.body.read)).tap{|info|
        not_a_robot!(info)
      }
    end

    def fail!(message)
      [ 400, { "Content-Type" => "text/plain"}, [message] ]
    end

    def not_a_robot!(info)
      # `reply_to_confirm` is a honeypot field, if it's filled it means it's a bot and an error is thrown
      raise ::Talktome::InvalidEmailError if info[:reply_to_confirm] && info[:reply_to_confirm] =~ /^[^@]+@[^@]+$/
    end

  end # class App
end # module Talktome
