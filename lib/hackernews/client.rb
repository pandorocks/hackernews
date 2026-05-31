# frozen_string_literal: true

require "httparty"
require "thread"

module Hackernews
  class Client
    include HTTParty

    FEEDS = {
      "top" => "topstories",
      "new" => "newstories",
      "best" => "beststories",
      "ask" => "askstories",
      "show" => "showstories",
      "jobs" => "jobstories"
    }.freeze

    DEFAULT_LIMIT = 500
    DEFAULT_PER_PAGE = 30
    DEFAULT_CONCURRENCY = 8

    base_uri "https://hacker-news.firebaseio.com/v0"

    def initialize(per_page: DEFAULT_PER_PAGE, limit: DEFAULT_LIMIT, concurrency: DEFAULT_CONCURRENCY)
      @per_page = per_page
      @limit = limit
      @concurrency = concurrency
    end

    def stories(feed:, page: 0)
      feed = feed.to_s
      ids = story_ids(feed).first(limit)
      page_ids = ids.slice(page.to_i * per_page, per_page) || []

      {
        feed: feed,
        page: page.to_i,
        ids: ids,
        stories: stories_for_ids(page_ids)
      }
    end

    def story_ids(feed)
      endpoint = FEEDS.fetch(feed.to_s) { FEEDS.fetch("top") }
      fetch_json("/#{endpoint}.json")
    end

    def item(id)
      Story.from_hash(fetch_json("/item/#{id}.json"))
    end

    private

    attr_reader :per_page, :limit, :concurrency

    def stories_for_ids(ids)
      return [] if ids.empty?

      work = Queue.new
      ids.each_with_index { |id, index| work << [index, id] }
      stories = Array.new(ids.length)
      errors = Queue.new

      [concurrency, ids.length].min.times.map do
        Thread.new do
          loop do
            index, id = work.pop(true)
            story = item(id)
            stories[index] = story if story&.readable?
          rescue ThreadError
            break
          rescue StandardError => e
            errors << e
            break
          end
        end
      end.each(&:join)

      raise errors.pop unless errors.empty?

      stories.compact
    end

    def fetch_json(path)
      response = self.class.get(path, timeout: 10)
      raise "Hacker News API returned #{response.code}" unless response.success?

      response.parsed_response
    end
  end
end
