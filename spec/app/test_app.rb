require 'spec_helper'

module Talktome
  describe App do
    include Rack::Test::Methods

    let(:app) {
      Talktome::App.new
    }

    before(:each) do
      ENV['TALKTOME_EMAIL_DEFAULT_FROM'] = "from@talktome.com"
      Mail::TestMailer.deliveries.clear
    end

    context 'POST /contact-us/, the basic contract' do

      it 'works' do
        post "/contact-us/", {
          email: 'hello@visitor.com',
          message: 'Hello from visitor'
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response).to be_ok
        expect(Mail::TestMailer.deliveries.length).to eql(1)
        expect(Mail::TestMailer.deliveries.first.from).to eql(["from@talktome.com"])
        expect(Mail::TestMailer.deliveries.first.to).to eql(["hello@visitor.com"])
        expect(Mail::TestMailer.deliveries.first.subject).to eql("Someone wants to reach you!")
      end

      it 'detects invalid emails' do
        post "/contact-us/", {
          email: 'helloatvisitor.com',
          message: 'Hello from visitor'
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eql(400)
        expect(Mail::TestMailer.deliveries.length).to eql(0)
      end

      it "detects invalid bodies" do
        post "/contact-us/", body: "foobar"
        expect(last_response.status).to eql(400)
        expect(Mail::TestMailer.deliveries.length).to eql(0)
      end

      it "detects stupid bots at least" do
        post "/contact-us/", {
          email: 'hello@visitor.com',
          message: 'Hello from visitor',
          confirmEmail: 'hello@visitor.com'
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eql(400)
        expect(Mail::TestMailer.deliveries.length).to eql(0)
      end

    end

    context 'POST /contact-us/, with a default Reply-To' do
      around(:each) do |bl|
        Talktome.set_env('TALKTOME_EMAIL_DEFAULT_REPLYTO', "info@talktome.com", &bl)
      end

      it 'works' do
        post "/contact-us/", {
          email: 'hello@visitor.com',
          message: 'Hello from visitor'
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response).to be_ok
        expect(Mail::TestMailer.deliveries.length).to eql(1)
        expect(Mail::TestMailer.deliveries.first.reply_to).to eql(["info@talktome.com"])
      end
    end

  end
end
