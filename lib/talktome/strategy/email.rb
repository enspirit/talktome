require 'mail'
module Talktome
  class Strategy
    class Email < Strategy

      def initialize(&defaulter)
        @defaulter = defaulter
      end

      def send_message(message, user, tpldata)
        message = message.instantiate(tpldata)
        mail = base_email
        mail.to = user[:email]
        mail.reply_to = message.metadata["reply_to"] if message.metadata.has_key?("reply_to")
        mail.subject = message.metadata["subject"]
        case message.extension
        when 'md', 'html', 'htm'
          mail.html_part do
            content_type 'text/html; charset=UTF-8'
            body message.template_content
          end
        when 'text'
          mail.body message.template_content
        else
          raise "Unsupported extension `#{message.extension}`"
        end
        mail.deliver!
      end

      def base_email
        default_email = Mail.new
        @defaulter.call(default_email) if @defaulter
        default_email
      end

    end # class Email
  end # class Strategy
end # module Talktome
