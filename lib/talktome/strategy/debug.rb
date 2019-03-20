module Talktome
  class Strategy
    class Debug

      attr_accessor :last

      def clear!
        @last = nil
      end

      def send_message(message, user)
        require 'ostruct'
        @last = OpenStruct.new({
          message: message,
          user: user
        })
        yield(@last) if block_given?
        @last
      end

    end # class Debug
  end # class Strategy
end # module Talktome
