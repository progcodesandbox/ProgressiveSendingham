require "rails_helper"

describe AuthController do
  describe "POST /auth/slack/handshake" do
    it "responds with the challenge parameter" do
      random_value = SecureRandom.hex(12)

      process :slack_handshake, method: :post, params: {
        challenge: random_value
      }

      challenge = JSON.parse(response.body)["challenge"]

      expect(challenge).to eq random_value
    end
  end
end
