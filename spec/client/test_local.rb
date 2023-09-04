require 'spec_helper'
module Talktome
  class Client
    describe Local do

      let(:strategy) {
        Strategy::Debug.new
      }

      let(:client){
        Local.new(folder, options) do |c|
          c.strategy :email, strategy
        end
      }

      let(:folder) {
        Path.dir/"../fixtures"
      }

      let(:user) {
        { email: "user@test.com" }
      }

      let(:tpldata) {
        {
          who: "Test user",
          lang: "en",
        }
      }

      before(:each) {
        strategy.clear!
      }

      context "without layouts" do
        let(:options) {
          {}
        }

        it 'sends email when requested' do
          client.talktome("welcome", user, tpldata, [:email])
          expect(strategy.last.message).not_to be_nil
          expect(strategy.last.message.to_html).to eql("<h1>Hello Test user</h1>\n\n<p>Welcome to this email example!</p>\n\n<h3>Test user</h3>\n")
        end
      end

      context "with layouts under the :layouts option key" do
        let(:options) {
          {
            layouts: Path.dir/"../fixtures/layouts"
          }
        }

        it 'sends email when requested' do
          client.talktome("welcome", user, tpldata, [:email])
          expect(strategy.last.message).not_to be_nil
          expect(strategy.last.message.to_html).to eql("<html lang='en'><title>Hello Test user</title><body><h1>Hello Test user</h1>\n\n<p>Welcome to this email example!</p>\n\n<h3>Test user</h3>\n</body></html>\n")
        end

        it 'yields the callback with the email' do
          seen = nil
          client.talktome("welcome", user, tpldata, [:email]){|m|
            seen = m
          }
          expect(seen).not_to be_nil
        end
      end

      context "with layouts under the :templates option key (backward compatibility)" do
        let(:options) {
          {
            templates: Path.dir/"../fixtures/layouts"
          }
        }

        it 'sends email when requested' do
          client.talktome("welcome", user, tpldata, [:email])
          expect(strategy.last.message.to_html).to eql("<html lang='en'><title>Hello Test user</title><body><h1>Hello Test user</h1>\n\n<p>Welcome to this email example!</p>\n\n<h3>Test user</h3>\n</body></html>\n")
        end

      end

    end
  end
end
