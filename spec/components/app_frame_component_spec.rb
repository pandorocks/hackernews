# frozen_string_literal: true

require "hackernews"

RSpec.describe Hackernews::AppFrameComponent do
  describe "#render" do
    it "returns a string" do
      component = described_class.new(title: "Hackernews")
      expect(component.render).to be_a(String)
    end
  end
end
