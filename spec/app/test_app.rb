require 'spec_helper'

module Talktome
  describe App do
    include Rack::Test::Methods

    let(:app) {
      Talktome::App.new
    }

    before(:each) do
      Talktome::App.set :talktome, Talktome::Client::Local.new(Path.dir.parent/'fixtures')
      ENV['TALKTOME_EMAIL_DEFAULT_TO'] = "to@talktome.com"
      ENV['TALKTOME_EMAIL_DEFAULT_FROM'] = "from@talktome.com"
      Mail::TestMailer.deliveries.clear
    end

    context 'POST /contact-us/, the basic contract' do

      it 'works' do
        post "/contact-us/", {
          reply_to: 'hello@visitor.com',
          message: 'Hello from visitor',
          key: 'value',
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response).to be_ok
        expect(Mail::TestMailer.deliveries.length).to eql(1)
        expect(Mail::TestMailer.deliveries.first.to).to eql(["to@talktome.com"])
        expect(Mail::TestMailer.deliveries.first.from).to eql(["from@talktome.com"])
        expect(Mail::TestMailer.deliveries.first.subject).to eql("Someone wants to reach you!")
        expect(Mail::TestMailer.deliveries.first.html_part.body).to include("<li>Key: value</li>")
        expect(Mail::TestMailer.deliveries.first.html_part.body).to include("Truly yours")
      end

      it 'allows to use environment variable to tune the subject and the footer' do
        Talktome.set_env('TALKTOME_EMAIL_SUBJECT', "Subject from environment") do
          Talktome.set_env('TALKTOME_EMAIL_FOOTER', "Footer from environment") do
            post "/contact-us/", {
              reply_to: 'info@domain.com',
              message: 'This is the message.'
            }.to_json, { "CONTENT_TYPE" => "application/json" }
            expect(last_response).to be_ok
            expect(Mail::TestMailer.deliveries.length).to eql(1)
            expect(Mail::TestMailer.deliveries.first.subject).to eql("Subject from environment")
            expect(Mail::TestMailer.deliveries.first.html_part.body).to include("Footer from environment")
          end
        end
      end

      it 'allows to use a token authentification to bypass default security measures, for e.g. passing the :to' do
        Talktome.set_env('TALKTOME_BEARER_SECRET', "Some secret") do
          header 'Authorization', 'Bearer Some secret'
          post "/contact-us/", {
            to: 'hello@visitor.com',
            reply_to: 'hello@visitor.com',
            message: 'Hello from visitor',
            key: 'value',
          }.to_json, { "CONTENT_TYPE" => "application/json" }
          expect(last_response).to be_ok
          expect(Mail::TestMailer.deliveries.length).to eql(1)
          expect(Mail::TestMailer.deliveries.first.to).to eql(["hello@visitor.com"])
          expect(Mail::TestMailer.deliveries.first.from).to eql(["from@talktome.com"])
        end
      end

      it 'detects invalid emails' do
        post "/contact-us/", {
          reply_to: 'helloatvisitor.com',
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
          reply_to: 'hello@visitor.com',
          message: 'Hello from visitor',
          reply_to_confirm: 'hello@visitor.com'
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eql(400)
        expect(Mail::TestMailer.deliveries.length).to eql(0)
      end

      it 'forbids usage of :to unless a secret is provided' do
        post "/contact-us/", {
          to: 'hello@visitor.com',
          reply_to: 'hello@visitor.com',
          message: 'Hello from visitor',
          key: 'value',
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eql(400)
        expect(Mail::TestMailer.deliveries.length).to eql(0)
      end

      it 'does not allow setting the :to without a valid AUTH token' do
        Talktome.set_env('TALKTOME_BEARER_SECRET', "Invalid secret") do
          post "/contact-us/", {
            to: 'hello@visitor.com',
            reply_to: 'hello@visitor.com',
            message: 'Hello from visitor',
            key: 'value',
          }.to_json, { "CONTENT_TYPE" => "application/json" }
          expect(last_response.status).to eql(401)
          expect(Mail::TestMailer.deliveries.length).to eql(0)
        end
      end

      it 'requires a valid Email for :to' do
        post "/contact-us/", {
          to: nil,
          reply_to: 'hello@visitor.com',
          message: 'Hello from visitor',
          key: 'value',
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eql(400)

        post "/contact-us/", {
          to: "notavalidemail",
          reply_to: 'hello@visitor.com',
          message: 'Hello from visitor',
          key: 'value',
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eql(400)
      end

    end

    context 'POST /contact-us/, regarding the Reply-To' do
      class ::Talktome::Message::Template
        def raise_on_context_miss?
          false
        end
      end

      around(:each) do |bl|
        Talktome.set_env('TALKTOME_EMAIL_DEFAULT_REPLYTO', "replyto@talktome.com", &bl)
      end

      it 'takes the default value from environment if set' do
        post "/contact-us/", {
          message: 'Hello from visitor'
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response).to be_ok
        expect(Mail::TestMailer.deliveries.length).to eql(1)
        expect(Mail::TestMailer.deliveries.first.reply_to).to eql(["replyto@talktome.com"])
      end

      it "lets override it by passing a replyTo field" do
        post "/contact-us/", {
          reply_to: 'hello@visitor.com',
          message: 'Hello from visitor'
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response).to be_ok
        expect(Mail::TestMailer.deliveries.length).to eql(1)
        expect(Mail::TestMailer.deliveries.first.reply_to).to eql(["hello@visitor.com"])
      end
    end

    context 'POST /multi-lingual/en/' do

      it 'works' do
        post "/multi-lingual/en/", {
          reply_to: 'hello@visitor.com',
          message: 'Hello from visitor',
          key: 'value',
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eql(200)
        expect(last_response).to be_ok
        expect(Mail::TestMailer.deliveries.length).to eql(1)
        expect(Mail::TestMailer.deliveries.first.to).to eql(["to@talktome.com"])
        expect(Mail::TestMailer.deliveries.first.from).to eql(["from@talktome.com"])
        expect(Mail::TestMailer.deliveries.first.subject).to eql("Someone wants to reach you!")
        expect(Mail::TestMailer.deliveries.first.html_part.body).to include("<li>Key: value</li>")
        expect(Mail::TestMailer.deliveries.first.html_part.body).to include("Truly yours")
      end
    end

  end
end
