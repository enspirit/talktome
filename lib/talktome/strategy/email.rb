require 'mail'
module Talktome
  class Strategy
    class Email < Strategy

      def initialize(options = {}, &defaulter)
        @options = options
        @defaulter = defaulter
      end

      def send_message(message, user)
        # Take a base email, with all info coming from the environment (if set)
        mail = base_email

        # Override environment defaults with template behavior, for flexibility
        [
          :to,
          :reply_to,
          :in_reply_to,
          :subject
        ].each do |which|
          if arg = message.metadata[which.to_s]
            mail.send(:"#{which}=", arg)
          end
        end

        # If the user is actually known from source code behavior, override the
        # `mail.to` to send the email to that particular person.
        mail.to = user[:email] if user.has_key?(:email)

        case message.extension
        when 'md', 'html', 'htm'
          mail.text_part do
            content_type 'text/plain; charset=UTF-8'
            body message.to_text
          end
          mail.html_part do
            content_type 'text/html; charset=UTF-8'
            body message.to_html
          end
        when 'text'
          mail.body message.to_text
        else
          raise "Unsupported extension `#{message.extension}`"
        end

        yield(mail) if block_given?

        mail.deliver!
      end

    private

      def base_email
        default_email = Mail.new
        @defaulter.call(default_email) if @defaulter
        default_email
      end

    end # class Email
  end # class Strategy
end # module Talktome
