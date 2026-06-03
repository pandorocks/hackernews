# frozen_string_literal: true

require "hackernews"

RSpec.describe Hackernews::Home::ShowView do
  describe "#render" do
    it "renders the state title" do
      view = described_class.new(
        home: Hackernews::HomeState.new,
        screen: Charming::Screen.new(width: 80, height: 24),
        theme: Hackernews::Application.new.theme
      )

      expect(view.render).to include("Hackernews")
    end
  end
end
