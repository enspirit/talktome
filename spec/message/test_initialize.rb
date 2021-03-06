require 'spec_helper'
module Talktome
  describe Message, 'initialize' do

    subject{
      Message.new path
    }

    context 'on a file with yaml frontmatter' do
      let(:path) { Path.dir/'with-frontmatter.md' }

      it 'works as expected' do
        expect(subject.template_content).to eql("Subject: {{metadata.subject}}\n\nHello {{who}} [test]({{url}})\n")
        expect(subject.metadata).to eql("hello" => "World", "subject" => "Hello {{who}}")
      end
    end

    context 'on a file without yaml frontmatter' do
      let(:path) { Path.dir/'without-frontmatter.md' }

      it 'works as expected' do
        expect(subject.template_content).to eql("Hello {{who}}\n")
        expect(subject.metadata).to eql({})
      end
    end

  end
end
