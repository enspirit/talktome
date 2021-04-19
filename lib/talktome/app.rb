require 'sinatra'
require 'finitio'

module Talktome
  class App < Sinatra::Application

    set :raise_errors, true
    set :show_exceptions, false

    VALIDATION_SCHEMA = ::Finitio.system(<<~FIO)
      @import finitio/data
      {
        email : String(s | s =~ /^[^@]+@[^@]+$/ )
        ...   : .Object
      }
    FIO

    TALKTOME = Talktome::Client::Local.new(ROOT_FOLDER/'mail-templates')

    post %r{/([a-z-]+)/} do |action|
      begin
        user = {
          email: info[:email]
        }
        TALKTOME.talktome(action, user, info, [:email])
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

  end
end # module Talktome
