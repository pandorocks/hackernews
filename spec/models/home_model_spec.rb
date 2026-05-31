# frozen_string_literal: true

require "hackernews"

RSpec.describe Hackernews::HomeModel do
  describe "#title" do
    it "has the correct default string value" do
      instance = described_class.new
      expect(instance.title).to eq("Hackernews")
    end

    it "accepts overridden title values" do
      instance = described_class.new(title: "Alternative")
      expect(instance.title).to eq("Alternative")
    end
  end

  describe "feed state" do
    it "defaults to the top feed" do
      instance = described_class.new

      expect(instance.feed).to eq("top")
      expect(instance.page_key).to eq("top:0")
    end

    it "keeps story caches in memory" do
      instance = described_class.new
      story = Hackernews::Story.new(
        id: 1,
        type: "story",
        by: "pg",
        time: 0,
        title: "Example",
        url: "https://example.com",
        score: 1,
        descendants: 0,
        text: ""
      )

      instance.stories_by_page[instance.page_key] = [story]

      expect(instance.cached_page?).to be(true)
      expect(instance.selected_story).to eq(story)
    end
  end
end
