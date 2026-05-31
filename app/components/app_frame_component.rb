# frozen_string_literal: true

module Hackernews
  class AppFrameComponent < Charming::Component
    def render
      column(*lines, gap: 1)
    end

    private

    def lines
      output = [title_line]
      output << status_line if home.error.to_s.strip != ""
      output << activity_line if home.working?
      output << content_line
      output << help_line
      output
    end

    def title_line
      text "#{home.title} / #{feed_title}", style: theme.title
    end

    def status_line
      text home.error, style: theme.warn
    end

    def activity_line
      render_component(Charming::Components::ActivityIndicator.new(
        width: activity_width,
        label: activity_label,
        index: home.activity_index,
        seed: "hackernews-loading",
        label_style: theme.muted
      ))
    end

    def content_line
      if home.reading?
        article_view
      else
        render_component(StoryListComponent.new(home: home, width: content_width, height: content_height, theme: theme))
      end
    end

    def article_view
      article = home.article || {}
      header = text(article.fetch(:url, ""), style: theme.muted)
      body = render_component(Charming::Components::Viewport.new(
        content: article.fetch(:markdown, ""),
        width: content_width,
        height: [content_height - 2, 1].max,
        offset: home.article_scroll,
        wrap: true
      ))
      column(header, body)
    end

    def help_line
      text help_text, style: theme.muted
    end

    def help_text
      if home.reading?
        "j/k scroll, pgup/pgdn jump, esc back. p commands, q quit."
      else
        "j/k move, enter read, r refresh, left/right page. p commands, q quit."
      end
    end

    def feed_title
      HomeController::FEEDS.fetch(home.feed).fetch(:title)
    end

    def content_width
      if screen.width < 72 && screen.height >= 20
        [screen.width - 12, 20].max
      else
        [screen.width - 42, 20].max
      end
    end

    def content_height
      [screen.height - 12, 5].max
    end

    def activity_label
      label = home.loading_label.to_s
      return label if Charming::UI::Width.measure(label) + 8 < content_width

      "Working"
    end

    def activity_width
      label_width = Charming::UI::Width.measure(activity_label)
      [[content_width - label_width - 4, 4].max, 24].min
    end
  end
end
