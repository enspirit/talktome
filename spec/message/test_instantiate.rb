require 'spec_helper'
module Talktome
  describe Message, 'instantiate' do

    subject{
      Message.new(path).instantiate(data)
    }

    describe "base contract" do
      let(:path) { Path.dir/'with-frontmatter.md' }
      let(:data) { { url: "http://foo", who: "bar"} }

      it 'works as expected' do
        expect(subject.template_content).to eql("Subject: Hello bar\n\nHello bar [test](http://foo)\n")
        expect(subject.metadata).to eql("hello" => "World", "subject" => "Hello bar")
      end
    end

    describe "security" do
      let(:path) { Path.dir/'security.md' }
      let(:data) { { url: "http://foo" } }

      it "doesn't have magic links" do
        expect(subject.template_content).to eql("Hello http://foo\n")
        expect(subject.to_html).to eql("<p>Hello http://foo</p>\n")
      end
    end

  end
end
