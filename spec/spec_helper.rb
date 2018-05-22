$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'talktome'

module SpecHelpers
end

RSpec.configure do |c|
  c.include SpecHelpers
end
