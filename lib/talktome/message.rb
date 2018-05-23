module Talktome
  class Message

    def initialize(path, options = {})
      @path = path
      @options = options
      compile
    end
    attr_accessor :path
    attr_accessor :metadata
    attr_accessor :template_content
    protected :path=, :metadata=, :template_content=

    def instantiate(tpldata)
      self.dup do |m|
        m.metadata = {}
        self.metadata.each_pair do |k, v|
          m.metadata[k] = i(v, tpldata)
        end
        m.template_content = i(m.template_content, tpldata.merge(metadata: m.metadata))
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

    def to_text
      template_it(self.template_content, :text)
    end

    def to_html
      case extension
      when 'md'
        template_it(Talktome.redcarpet.render(self.template_content), :html)
      else
        template_it(self.template_content, :html)
      end
    end

  private

    def template_it(src, ctype)
      if @options[:templater]
        @options[:templater].call(self, src, ctype)
      else
        src
      end
    end

    def i(tpl, tpldata)
      Mustache.render(tpl, tpldata)
    end

    def compile
      raw = path.read.force_encoding(Encoding::UTF_8)
      if raw =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
        @metadata, @template_content = YAML::load($1), $'
      else
        @metadata, @template_content = {}, raw
      end
    end

  end # module Message
end # module Talktome
