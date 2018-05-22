require 'yaml'
require 'path'
require 'mustache'
require 'redcarpet'
module Talktome

  def redcarpet
    @redcarpet ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
  end
  module_function :redcarpet

end
require 'talktome/version'
require 'talktome/error'
require 'talktome/strategy'
require 'talktome/message'
require 'talktome/client'
