# frozen_string_literal: true

require "hackernews"

RSpec.describe Hackernews::HomeController do
  let(:application) { Hackernews::Application.new }

  subject(:controller) { described_class.new(application: application) }

  describe "#show" do
    it "renders the view with the model" do
      response = controller.dispatch(:show)

      expect(response).to respond_to(:body)
    end
  end
end
