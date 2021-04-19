require 'spec_helper'

module Talktome
  describe App do
    include Rack::Test::Methods

    let(:app) {
      Talktome::App.new
    }

    context 'POST /contact-us/' do

      it 'works' do
        post "/contact-us/", {
          email: 'hello@visitor.com',
          message: 'Hello from visitor'
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response).to be_ok
      end

      it 'detects invalid emails' do
        post "/contact-us/", {
          email: 'helloatvisitor.com',
          message: 'Hello from visitor'
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eql(400)
      end

      it "detects invalid bodies" do
        post "/contact-us/", body: "foobar"
        expect(last_response.status).to eql(400)
      end

      it "detects stupid bots at least" do
        post "/contact-us/", {
          email: 'hello@visitor.com',
          message: 'Hello from visitor',
          confirmEmail: 'hello@visitor.com'
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response.status).to eql(400)
      end

    end

    context 'POST /customer-support/' do

      it 'works' do
        post "/customer-support/", {
          email: 'help@example.com',
          message: 'Please help me',
          object: 'The object',
          kind: 'Kind',
          info: {
            version: '1.0.1',
            page: 'homepage'
          }
        }.to_json, { "CONTENT_TYPE" => "application/json" }
        expect(last_response).to be_ok
      end
    end

  end
end
