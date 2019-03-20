module Talktome
  class Client

    def initialize(folder, options = {})
      raise ArgumentError, "Missing root folder" unless folder
      raise ArgumentError, "Invalid root folder" unless Path(folder).directory?
      @folder = folder
      @options = Talktome.auto_options(folder).merge(options)
      yield self if block_given?
    end
    attr_reader :folder, :options

    def strategy(name, stragegy)
      strategies[name] = stragegy
    end

  protected

    def strategies
      options[:strategies]
    end

    def get_handler(strategy)
      strategies[strategy]
    end

  end # class Client
end # module Talktome
require 'talktome/client/local'
