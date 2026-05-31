# frozen_string_literal: true

require "hackernews"

RSpec.describe Hackernews::ArticleExtractor do
  it "extracts markdown with the trafilatura CLI" do
    status = instance_double(Process::Status, success?: true)
    expect(Open3).to receive(:capture3).with(
      "trafilatura",
      "--markdown",
      "--images",
      "--no-comments",
      "--no-tables",
      "-u",
      "https://example.com/article"
    ).and_return(["# Article", "", status])

    article = described_class.new.extract("https://example.com/article")

    expect(article).to eq(url: "https://example.com/article", markdown: "# Article")
  end
end
