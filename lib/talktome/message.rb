module Talktome
  class Message

    def initialize(path)
      @path = path
      compile
    end
    attr_accessor :path
    attr_accessor :metadata
    attr_accessor :template_content
    protected :path=, :metadata=, :template_content=

    def instantiate(tpldata)
      self.dup do |m|
        m.template_content = i(m.template_content, tpldata)
        m.metadata = {}
        self.metadata.each_pair do |k, v|
          m.metadata[k] = i(v, tpldata)
        end
      end
    end

    def dup
      d = super
      yield(d) if block_given?
      d
    end

    def extension
      path.ext.to_s
    end

  private

    def i(tpl, tpldata)
      Mustache.render(tpl, tpldata)
    end

    def compile
      raw = path.read
      if raw =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
        @metadata, @template_content = YAML::load($1), compile_body($')
      else
        @metadata, @template_content = {}, compile_body(raw)
      end
    end

    def compile_body(body)
      case extension
      when 'md'
        Talktome.redcarpet
          .render(body)
          .gsub(/%7B%7B/, '{{')
          .gsub(/%7D%7D/, '}}')
      else
        body
      end
    end

  end # module Message
end # module Talktome
