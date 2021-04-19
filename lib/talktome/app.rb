require 'sinatra'

module Talktome
  class App < Sinatra::Application

    set :raise_errors, true
    set :show_exceptions, false

    post '/contact-us/' do
      begin
        body = request.body.read
        info = JSON.parse(body)
        raise ::Talktome::InvalidEmailError unless info['email'] && info['email'] =~ /^[^@]+@[^@]+$/
        # `confirmEmail` is a honeypot field, if it's filled it means it's a bot and an error is thrown
        raise ::Talktome::InvalidEmailError if info['confirmEmail'] && info['confirmEmail'] =~ /^[^@]+@[^@]+$/
        user = {
          email: info['email']
        }
        data = {
          email: info['email'],
          message: info['message'] || ''
        }

        TALKTOME = Talktome::Client::Local.new(ROOT_FOLDER/'mail-templates')
        TALKTOME.talktome('contact-us', user, data, [:email])
        [ 200, { "Content-Type" => "text/plain"}, ["Ok"] ]
      rescue JSON::ParserError, ::Talktome::InvalidEmailError => ex
        [ 400, { "Content-Type" => "text/plain"}, ["Invalid email address"] ]
      end
    end

  end
end # module Talktome
