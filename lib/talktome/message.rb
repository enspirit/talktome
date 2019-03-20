module Talktome
  class Message

    def initialize(path, options = {})
      @path = path
      @options = options
      compile
    end
    attr_accessor :path
    attr_accessor :metadata
    attr_accessor :data
    attr_accessor :template_content
    protected :path=, :metadata=, :data=, :template_content=

    def instantiate(tpldata)
      self.dup do |m|
        m.metadata = {}
        self.metadata.each_pair do |k, v|
          m.metadata[k] = i(v, tpldata)
        end
        m.template_content = i(m.template_content, tpldata.merge(metadata: m.metadata))
        m.data = tpldata
      end
    end

    def dup
      d = super
      yield(d) if block_given?
      d
    end

    def extension
      path.ext.to_s.gsub(/^\./,"")
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

    class Template < Mustache

      def partial(name)
        path = "#{@options[:template_path]}/#{name}.#{template_extension}"
        File.read(path).force_encoding(Encoding::UTF_8)
      end

      def raise_on_context_miss?
        true
      end

    end

    def template_it(src, ctype)
      if @options[:templater]
        @options[:templater].call(self, src, ctype)
      else
        src
      end
    end

    def i(tpl, tpldata)
      Template.new({
        template_file: self.path,
        template_path: self.path.parent
      }).render(tpl, tpldata)
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
