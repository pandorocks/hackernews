# frozen_string_literal: true

require "hackernews"

RSpec.describe Hackernews::Story do
  it "normalizes Hacker News item hashes" do
    story = described_class.from_hash(
      "id" => 42,
      "type" => "story",
      "title" => "Ruby",
      "url" => "https://www.example.com/post"
    )

    expect(story).to be_readable
    expect(story.domain).to eq("example.com")
    expect(story.article_url).to eq("https://www.example.com/post")
  end
end
