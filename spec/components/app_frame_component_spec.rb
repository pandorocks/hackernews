# frozen_string_literal: true

require "hackernews"

RSpec.describe Hackernews::AppFrameComponent do
  describe "#render" do
    it "returns a string" do
      component = described_class.new(
        home: Hackernews::HomeState.new,
        screen: Charming::Screen.new(width: 80, height: 24)
      )
      expect(component.render).to be_a(String)
    end

    it "wraps article content inside the viewport" do
      home = Hackernews::HomeState.new(reading_story_id: 1)
      home.articles_by_story_id[1] = {url: "https://example.com", markdown: "abcdefghijklmnopqrstuvwxyz"}
      component = described_class.new(
        home: home,
        screen: Charming::Screen.new(width: 48, height: 24)
      )

      plain = Charming::UI::Width.strip_ansi(component.render)

      expect(plain).to include("abcdefghijklmnopqrst")
      expect(plain).to include("uvwxyz")
    end

    it "renders article markdown inside the viewport" do
      home = Hackernews::HomeState.new(reading_story_id: 1)
      home.articles_by_story_id[1] = {
        url: "https://example.com/posts/article",
        markdown: "# Article\n\nRead **bold** [docs](/docs)."
      }
      component = described_class.new(
        home: home,
        screen: Charming::Screen.new(width: 80, height: 24)
      )

      plain = Charming::UI::Width.strip_ansi(component.render)

      expect(plain).to include("Article")
      expect(plain).to include("Read bold docs")
      expect(plain).to include("<https://example.com/docs>")
      expect(plain).not_to include("# Article")
      expect(plain).not_to include("**bold**")
      expect(plain).not_to include("[docs](/docs)")
    end

    it "does not render feed loading once the current page is cached" do
      home = Hackernews::HomeState.new(loading: true, loading_label: "Loading Top Stories")
      home.stories_by_page[home.page_key] = [Hackernews::Story.new(
        id: 1,
        type: "story",
        by: "pg",
        time: 0,
        title: "Cached story",
        url: "https://example.com",
        score: 1,
        descendants: 0,
        text: ""
      )]
      component = described_class.new(
        home: home,
        screen: Charming::Screen.new(width: 80, height: 24)
      )

      plain = Charming::UI::Width.strip_ansi(component.render)

      expect(plain).not_to include("Loading Top Stories")
      expect(plain).to include("Cached story")
    end
  end
end
