require 'sinatra'
require 'finitio'

module Talktome
  class App < Sinatra::Application

    set :raise_errors, true
    set :show_exceptions, false

    VALIDATION_SCHEMA = ::Finitio.system(<<~FIO)
      @import finitio/data
      Email = String(s | s =~ /^[^@]+@[^@]+$/ )
      {
        email    :? Email
        reply_to :? Email
        ...      :  .Object
      }
    FIO

    TALKTOME = Talktome::Client::Local.new(ROOT_FOLDER/'templates')

    post %r{/([a-z-]+)/} do |action|
      begin
        TALKTOME.talktome(action, {}, info, [:email]){|email|
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
      # `confirmEmail` is a honeypot field, if it's filled it means it's a bot and an error is thrown
      raise ::Talktome::InvalidEmailError if info[:confirmEmail] && info[:confirmEmail] =~ /^[^@]+@[^@]+$/
    end

  end # class App
end # module Talktome
