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
        { who: "Test user" }
      }

      before(:each) {
        strategy.clear!
      }

      context "without templates" do
        let(:options) {
          {}
        }

        it 'sends email when requested' do
          client.talktome("welcome", user, tpldata, [:email])
          expect(strategy.last.message).not_to be_nil
          expect(strategy.last.message.to_html).to eql("<h1>Hello Test user</h1>\n\n<p>Welcome to this email example!</p>\n")
        end
      end

      context "with templates" do
        let(:options) {
          {
            templates: Path.dir/"../fixtures/templates"
          }
        }

        it 'sends email when requested' do
          client.talktome("welcome", user, tpldata, [:email])
          expect(strategy.last.message).not_to be_nil
          expect(strategy.last.message.to_html).to eql("<html><title>Hello Test user</title><body><h1>Hello Test user</h1>\n\n<p>Welcome to this email example!</p>\n</body></html>\n")
        end
      end

    end
  end
end
