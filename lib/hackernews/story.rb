# frozen_string_literal: true

require "cgi"
require "uri"

module Hackernews
  Story = Data.define(:id, :type, :by, :time, :title, :url, :score, :descendants, :text) do
    def self.from_hash(hash)
      return unless hash

      new(
        id: hash.fetch("id", nil),
        type: hash.fetch("type", nil),
        by: hash.fetch("by", ""),
        time: hash.fetch("time", 0).to_i,
        title: hash.fetch("title", "Untitled"),
        url: hash.fetch("url", ""),
        score: hash.fetch("score", 0).to_i,
        descendants: hash.fetch("descendants", 0).to_i,
        text: hash.fetch("text", "")
      )
    end

    def readable?
      %w[story job poll].include?(type)
    end

    def article_url
      url.to_s.strip.empty? ? "https://news.ycombinator.com/item?id=#{id}" : url
    end

    def domain
      return "news.ycombinator.com" if url.to_s.strip.empty?

      URI.parse(url).hostname.to_s.delete_prefix("www.")
    rescue URI::InvalidURIError
      ""
    end

    def hn_markdown
      body = CGI.unescapeHTML(text.to_s)
      body = body.gsub("<p>", "\n\n")
      body = body.gsub("<pre><code>", "\n\n```")
      body = body.gsub("</code></pre>", "```\n\n")
      "# #{title}\n\n#{body}"
    end
  end
end
