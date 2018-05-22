module Talktome
  class Client
    class Local < Client

      def initialize(folder)
        raise ArgumentError, "Missing messages folder" unless folder
        raise ArgumentError, "Invalid messages folder" unless Path(folder).directory?
        @folder = folder
        super()
      end
      attr_reader :folder

      def talktome(message, user, tpldata, strategies)
        message, handler = load_message!(message, strategies)
        handler.send_message message, user, tpldata
      end

    protected

      def load_message!(identifier, strategies)
        folder = self.folder/identifier
        raise InvalidMessageError, "No such message `#{identifier}`"            unless folder.exists?
        raise InvalidMessageError, "Message `#{identifier}` should be a folder" unless folder.directory?
        strategies.each do |s|
          if (file = folder.glob("#{s}.*").first).file?
            message = Message.new(file)
            handler = get_handler(s)
            return [ message, handler ]
          end
        end
        files = folder.glob("*").map{|f| f.basename.to_s }
        raise InvalidMessageError, "No available strategy for `#{identifier}`\n#{files.inspect} vs. #{strategies.inspect}"
      end

    end # class Client
  end # class Client
end # module Talktome
