# frozen_string_literal: true

module Hackernews
  module Home
    class ShowView < Charming::View
      def render
        render_component AppFrameComponent.new(home: home, screen: screen, theme: theme)
      end
    end
  end
end
