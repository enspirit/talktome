require 'yaml'
require 'path'
require 'mustache'
require 'redcarpet'
module Talktome

  # Root folder of the project structure
  ROOT_FOLDER = Path.backfind('.[Gemfile]') or raise("Missing Gemfile")

  def env(which, default = nil)
    if ENV.has_key?(which)
      got = ENV[which].to_s.strip
      return got unless got.empty?
    end
    default
  end
  module_function :env

  def with_env(which, &bl)
    env(which).tap{|x|
      bl.call(x) unless x.nil?
    }
  end
  module_function :with_env

  def set_env(which, value, &bl)
    old, ENV[which] = ENV[which], value
    bl.call.tap{
      ENV[which] = old
    }
  end
  module_function :set_env

  def redcarpet
    @redcarpet ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
  end
  module_function :redcarpet

  # Infer all client and strategy options from environment variables.
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
      port:      ENV['TALKTOME_SMTP_PORT'].to_i,
      domain:    ENV['TALKTOME_SMTP_DOMAIN'],
      user_name: ENV['TALKTOME_SMTP_USER'],
      password:  ENV['TALKTOME_SMTP_PASSWORD'],
      enable_starttls_auto: (ENV['TALKTOME_SMTP_STARTTLS_AUTO'] != 'false'),
      openssl_verify_mode: ENV['TALKTOME_SMTP_OPENSSL_VERIFY_MODE'] || "peer",
    }) if email_delivery == :smtp

    email_config.merge!({
      location: debug_folder.mkdir_p
    }) if email_delivery == :file

    options[:strategies][:email] = ::Talktome::Strategy::Email.new{|email|
      email.delivery_method(email_delivery, email_config)
      with_env('TALKTOME_EMAIL_DEFAULT_FROM'){|default|
        email.from(default)
      }
      with_env('TALKTOME_EMAIL_DEFAULT_TO'){|default|
        email.to(default)
      }
      with_env('TALKTOME_EMAIL_DEFAULT_REPLYTO'){|default|
        email.reply_to(default)
      }
    }

    if layouts_folder = ENV['TALKTOME_LAYOUTS_FOLDER']
      options[:layouts] = Path(layouts_folder)
    end

    options
  end
  module_function :auto_options

end
require 'talktome/version'
require 'talktome/error'
require 'talktome/strategy'
require 'talktome/message'
require 'talktome/client'
