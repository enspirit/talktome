require 'mail'
module Talktome
  class Strategy
    class Email < Strategy

      def initialize(options = {}, &defaulter)
        @options = options
        @defaulter = defaulter
      end

      def send_message(message, user)
        mail = base_email
        mail.to = user[:email]
        mail.reply_to = message.metadata["reply_to"] if message.metadata.has_key?("reply_to")
        mail.subject  = message.metadata["subject"]

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
