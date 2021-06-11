module Talktome
  class Error < StandardError; end
  class InvalidMessageError < Error; end
  class InvalidEmailError < Error; end
  class TemplateNotFoundError < Error; end
end
