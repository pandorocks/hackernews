# frozen_string_literal: true

module Hackernews
  class HomeController < ApplicationController
    FEEDS = {
      "top" => {title: "Top Stories", path: "/"},
      "new" => {title: "New", path: "/new"},
      "best" => {title: "Best", path: "/best"},
      "ask" => {title: "Ask HN", path: "/ask"},
      "show" => {title: "Show HN", path: "/show"},
      "jobs" => {title: "Jobs", path: "/jobs"}
    }.freeze

    key "r", :refresh
    key "up", :move_up
    key "k", :move_up
    key "down", :move_down
    key "j", :move_down
    key "page_up", :page_up
    key "page_down", :page_down
    key "left", :previous_page
    key "right", :next_page
    key "n", :next_page
    key "enter", :open_selected_story
    key "escape", :close_article

    timer :activity, every: 0.12, action: :tick_activity
    on_task :load_feed, action: :load_feed_done
    on_task :extract_article, action: :extract_article_done

    def show
      ensure_feed_loaded
      render :show, home: home, palette: command_palette
    end

    def new
      switch_feed("new")
    end

    def best
      switch_feed("best")
    end

    def ask
      switch_feed("ask")
    end

    def show_hn
      switch_feed("show")
    end

    def jobs
      switch_feed("jobs")
    end

    def refresh
      key = home.page_key
      home.stories_by_page.delete(key)
      home.story_ids_by_feed.delete(home.feed)
      home.failed_pages.delete(key)
      start_feed_load(force: true)
      render :show, home: home, palette: command_palette
    end

    def tick_activity
      home.activity_index += 1 if home.working?
      show
    end

    def load_feed_done
      value = event.value || {}
      feed = value[:feed] || home.feed
      page = value[:page] || home.page
      key = home.page_key(feed, page)
      current_page = feed == home.feed && page == home.page

      if value[:error]
        home.error = value[:error]
        home.failed_pages[key] = true
      else
        home.error = ""
        home.failed_pages.delete(key)
        home.story_ids_by_feed[value.fetch(:feed)] = value.fetch(:ids)
        home.stories_by_page[key] = value.fetch(:stories)
        home.selected_index = 0 if current_page
      end

      if home.loading_key == key || current_page
        home.loading = false
        home.loading_key = nil
      end

      show
    end

    def extract_article_done
      value = event.value || {}
      story_id = value[:story_id].to_i
      home.extracting_story_id = nil if home.extracting_story_id.to_i == story_id

      if value[:error]
        home.error = value[:error]
      else
        home.error = ""
        home.articles_by_story_id[story_id] = value.fetch(:article)
        home.reading_story_id = story_id
        home.article_scroll = 0
      end

      show
    end

    def move_up
      if home.reading?
        home.article_scroll = [home.article_scroll - 1, 0].max
      else
        home.selected_index = [home.selected_index - 1, 0].max
      end
      show
    end

    def move_down
      if home.reading?
        home.article_scroll += 1
      else
        max = [home.current_stories.length - 1, 0].max
        home.selected_index = [home.selected_index + 1, max].min
      end
      show
    end

    def page_up
      if home.reading?
        home.article_scroll = [home.article_scroll - 10, 0].max
      else
        home.selected_index = [home.selected_index - 10, 0].max
      end
      show
    end

    def page_down
      if home.reading?
        home.article_scroll += 10
      else
        max = [home.current_stories.length - 1, 0].max
        home.selected_index = [home.selected_index + 10, max].min
      end
      show
    end

    def previous_page
      return show if home.reading?
      return show if home.page.to_i <= 0

      home.page -= 1
      home.reset_list_position
      show
    end

    def next_page
      return show if home.reading?
      return show unless more_pages?

      home.page += 1
      home.reset_list_position
      show
    end

    def open_selected_story
      story = home.selected_story
      return show unless story

      if home.articles_by_story_id.key?(story.id)
        home.reading_story_id = story.id
        home.article_scroll = 0
      elsif story.url.to_s.strip.empty?
        home.articles_by_story_id[story.id] = {url: story.article_url, markdown: story.hn_markdown}
        home.reading_story_id = story.id
        home.article_scroll = 0
      else
        start_article_extract(story)
      end

      show
    end

    def close_article
      home.reading_story_id = nil
      home.article_scroll = 0
      show
    end

    def current_route?(route)
      route.path == FEEDS.fetch(home.feed).fetch(:path)
    end

    private

    def home
      state(:home, HomeState)
    end

    def switch_feed(feed)
      home.feed = feed
      home.page = 0
      home.error = ""
      home.reset_list_position
      show
    end

    def ensure_feed_loaded
      return if home.cached_page? || home.failed_page?

      start_feed_load
    end

    def start_feed_load(force: false)
      key = home.page_key
      return if home.loading_key == key
      return if home.cached_page? && !force

      feed = home.feed
      page = home.page
      home.loading = true
      home.loading_key = key
      home.loading_label = "Loading #{FEEDS.fetch(feed).fetch(:title)}"
      home.error = ""

      run_task(:load_feed) do
        client_result = Client.new.stories(feed: feed, page: page)
        client_result.merge(feed: feed, page: page)
      rescue StandardError => e
        {feed: feed, page: page, error: e.message}
      end
    end

    def start_article_extract(story)
      return if home.extracting_story_id.to_i == story.id

      home.extracting_story_id = story.id
      home.loading_label = "Extracting article"
      home.error = ""

      run_task(:extract_article) do
        {story_id: story.id, article: ArticleExtractor.new.extract(story.url)}
      rescue StandardError => e
        {story_id: story.id, error: e.message}
      end
    end

    def more_pages?
      ids = home.current_story_ids
      return true if ids.empty?

      (home.page + 1) * Client::DEFAULT_PER_PAGE < ids.length
    end
  end
end
