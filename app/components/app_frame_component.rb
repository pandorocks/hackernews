# frozen_string_literal: true

module Hackernews
  class AppFrameComponent < Charming::Component
    def render
      column(title_line, help_line, gap: 1)
    end

    private

    def title_line
      text title, style: theme.title
    end

    def help_line
      text "Press p for commands, q to quit.", style: theme.muted
    end
  end
end
