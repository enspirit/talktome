require 'spec_helper'
module Talktome
  describe Message, 'instantiate' do

    subject{
      Message.new(path).instantiate(data)
    }

    let(:path) { Path.dir/'with-frontmatter.md' }
    let(:data) { { url: "http://foo", who: "bar"} }

    it 'works as expected' do
      expect(subject.template_content).to eql("Subject: Hello bar\n\nHello bar [test](http://foo)\n")
      expect(subject.metadata).to eql("hello" => "World", "subject" => "Hello bar")
    end

  end
end
