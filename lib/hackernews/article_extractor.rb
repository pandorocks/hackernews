# frozen_string_literal: true

require "open3"
require "timeout"

module Hackernews
  class ArticleExtractor
    COMMAND = "trafilatura"
    TIMEOUT = 30

    def extract(url)
      url = url.to_s.strip
      raise ArgumentError, "story has no article URL" if url.empty?

      stdout, stderr, status = Timeout.timeout(TIMEOUT) do
        Open3.capture3(COMMAND, "--markdown", "--images", "--no-comments", "--no-tables", "-u", url)
      end

      unless status.success?
        message = stderr.strip.empty? ? stdout.strip : stderr.strip
        raise "trafilatura extraction failed: #{message}"
      end

      markdown = stdout.strip
      raise "trafilatura did not find readable article content" if markdown.empty?

      {url: url, markdown: markdown}
    rescue Errno::ENOENT
      raise "trafilatura is required. Install it separately and ensure `trafilatura` is on PATH."
    rescue Timeout::Error
      raise "article extraction timed out"
    end
  end
end
