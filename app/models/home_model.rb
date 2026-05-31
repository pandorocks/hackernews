# frozen_string_literal: true

module Hackernews
  class HomeModel < ApplicationModel
    attribute :title, :string, default: "Hackernews"
    attribute :feed, :string, default: "top"
    attribute :page, :integer, default: 0
    attribute :selected_index, :integer, default: 0
    attribute :loading, :boolean, default: false
    attribute :loading_label, :string, default: ""
    attribute :error, :string, default: ""
    attribute :activity_index, :integer, default: 0
    attribute :reading_story_id, :integer
    attribute :article_scroll, :integer, default: 0

    attr_accessor :story_ids_by_feed, :stories_by_page, :articles_by_story_id,
      :failed_pages, :loading_key, :extracting_story_id

    def initialize(**attributes)
      super
      @story_ids_by_feed = {}
      @stories_by_page = {}
      @articles_by_story_id = {}
      @failed_pages = {}
    end

    def page_key(feed_name = feed, page_number = page)
      "#{feed_name}:#{page_number.to_i}"
    end

    def current_stories
      stories_by_page.fetch(page_key, [])
    end

    def current_story_ids
      story_ids_by_feed.fetch(feed, [])
    end

    def cached_page?
      stories_by_page.key?(page_key)
    end

    def failed_page?
      failed_pages[page_key]
    end

    def selected_story
      current_stories[selected_index]
    end

    def selected_story=(story)
      self.selected_index = current_stories.index(story) || 0
    end

    def article
      articles_by_story_id[reading_story_id]
    end

    def reading?
      reading_story_id.to_i.positive?
    end

    def working?
      (loading && !cached_page?) || extracting_story_id.to_i.positive?
    end

    def reset_list_position
      self.selected_index = 0
      self.article_scroll = 0
      self.reading_story_id = nil
    end
  end
end
