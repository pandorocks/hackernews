# frozen_string_literal: true

module Hackernews
  class StoryListComponent < Charming::Component
    def render
      return empty_state if home.current_stories.empty?

      column(*story_lines, footer_line, gap: 1)
    end

    private

    def empty_state
      message = if home.loading
        ""
      elsif home.error.to_s.strip != ""
        "Press r to retry."
      else
        "No stories loaded. Press r to refresh."
      end

      text message, style: theme.muted
    end

    def story_lines
      visible_stories.each_with_index.map do |story, index|
        absolute_index = viewport_start + index
        rank = (home.page * Client::DEFAULT_PER_PAGE) + absolute_index + 1
        title = "#{rank}. #{story.title}"
        title += " (#{story.domain})" unless story.domain.empty?
        meta = "   #{story.score} points by #{story.by} | #{story.descendants} comments"
        line = "#{title}\n#{meta}"
        absolute_index == home.selected_index ? text(line, style: theme.selected) : text(line)
      end
    end

    def footer_line
      text footer_text, style: theme.muted
    end

    def footer_text
      total = home.current_story_ids.length
      loaded = home.current_stories.length
      page = home.page + 1
      return "Page #{page} | #{loaded} loaded" if total.zero?

      "Page #{page}/#{page_count(total)} | #{loaded} loaded on this page | #{total} ids cached"
    end

    def visible_stories
      home.current_stories.slice(viewport_start, viewport_height) || []
    end

    def viewport_start
      (home.selected_index - viewport_height + 1).clamp(0, max_viewport_start)
    end

    def viewport_height
      [height.to_i / 3, 1].max
    end

    def max_viewport_start
      [home.current_stories.length - viewport_height, 0].max
    end

    def page_count(total)
      (total.to_f / Client::DEFAULT_PER_PAGE).ceil
    end
  end
end
