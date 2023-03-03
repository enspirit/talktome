$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'base64'
require 'talktome'
require 'talktome/app'
require 'rack/test'

module SpecHelpers
end

RSpec.configure do |c|
  c.include SpecHelpers
end
