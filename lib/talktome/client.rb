module Talktome
  class Client

    def initialize
      @strategies = {}
      yield self if block_given?
    end

    def strategy(name, stragegy)
      @strategies[name] = stragegy
    end

  protected

    def get_handler(strategy)
      @strategies[strategy]
    end

  end # class Client
end # module Talktome
require 'talktome/client/local'
