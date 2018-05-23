module Talktome
  class Client
    class Local < Client

      def initialize(folder, options = {})
        raise ArgumentError, "Missing messages folder" unless folder
        raise ArgumentError, "Invalid messages folder" unless Path(folder).directory?
        @folder = folder
        @options = options
        super()
      end
      attr_reader :folder, :options

      def talktome(message, user, tpldata, strategies)
        message, handler = load_message!(message, strategies)
        message = message.instantiate(tpldata)
        options[:debugger].call(message, user, handler) if options[:debugger]
        handler.send_message message, user
      end

    protected

      def load_message!(identifier, strategies)
        folder = self.folder/identifier
        raise InvalidMessageError, "No such message `#{identifier}`"            unless folder.exists?
        raise InvalidMessageError, "Message `#{identifier}` should be a folder" unless folder.directory?
        strategies.each do |s|
          if (file = folder.glob("#{s}.*").first) && file.file?
            handler = get_handler(s)
            options = {}
            options[:templater] = templater(s)
            message = Message.new(file, options)
            return [ message, handler ]
          end
        end
        files = folder.glob("*").map{|f| f.basename.to_s }
        raise InvalidMessageError, "No available strategy for `#{identifier}`\n#{files.inspect} vs. #{strategies.inspect}"
      end

      def templater(strategy)
        return nil unless tpl_folder = options[:templates]
        ->(message, src, ctype) {
          if (file = tpl_folder/"#{strategy}.#{ctype}").file?
            data = { metadata: message.metadata, yield: src }
            Mustache.render(file.read, data)
          else
            src
          end
        }
      end

    end # class Client
  end # class Client
end # module Talktome
