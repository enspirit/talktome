require 'yaml'
require 'path'
require 'mustache'
require 'redcarpet'
module Talktome

  def redcarpet
    @redcarpet ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
  end
  module_function :redcarpet

  #
  # Infer all client and strategy options from environment variables.
  # The following ones are recognized:
  #
  # - TALKTOME_DEBUG: when set (to anything) enables the dumping of sent
  #   messages to the debug folder
  # - TALKTOME_EMAIL_DELIVERY: "smtp", "file" or "test"
  # - TALKTOME_EMAIL_DEFAULT_FROM: default from address to use for email sending
  # - TALKTOME_SMTP_ADDRESS: host address for smtp sending
  # - TALKTOME_SMTP_PORT: port of smtp server to use
  # - TALKTOME_SMTP_DOMAIN: sending domain
  # - TALKTOME_SMTP_USER: user for smtp authentication
  # - TALKTOME_SMTP_PASSWORD: user for smtp authentication
  #
  def auto_options(folder)
    options = {}
    debug_folder = folder/"tmp"

    options[:debugger] = ->(message, user, handler) {
      debug_folder.mkdir_p unless debug_folder.exists?
      (debug_folder/"#{user[:email]}.html").write(message.to_html)
      (debug_folder/"#{user[:email]}.txt").write(message.to_text)
    } if ENV['TALKTOME_DEBUG']

    options[:strategies] = {}

    email_delivery = (ENV['TALKTOME_EMAIL_DELIVERY'] || "test").to_sym
    email_config   = {}

    email_config.merge!({
      address:   ENV['TALKTOME_SMTP_ADDRESS'],
      port:      ENV['TALKTOME_SMTP_PORT'],
      domain:    ENV['TALKTOME_SMTP_DOMAIN'],
      user_name: ENV['TALKTOME_SMTP_USER'],
      password:  ENV['TALKTOME_SMTP_PASSWORD']
    }) if email_delivery == :smtp

    email_config.merge!({
      location: debug_folder.mkdir_p
    }) if email_delivery == :file

    options[:strategies][:email] = ::Talktome::Strategy::Email.new{|email|
      email.delivery_method(email_delivery, email_config)
      email.from(ENV['TALKTOME_EMAIL_DEFAULT_FROM']) if ENV['TALKTOME_EMAIL_DEFAULT_FROM']
    }

    options
  end
  module_function :auto_options

end
require 'talktome/version'
require 'talktome/error'
require 'talktome/strategy'
require 'talktome/message'
require 'talktome/client'
