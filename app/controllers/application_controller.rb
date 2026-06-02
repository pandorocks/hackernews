# frozen_string_literal: true

module Hackernews
  class ApplicationController < Charming::Controller
    layout Layouts::ApplicationLayout
    focus_ring :content, :sidebar

    key "p", :open_command_palette, scope: :global
    key "q", :quit, scope: :global

    command "Top" do
      navigate_to "/"
    end

    command "New" do
      navigate_to "/new"
    end

    command "Best" do
      navigate_to "/best"
    end

    command "Ask HN" do
      navigate_to "/ask"
    end

    command "Show HN" do
      navigate_to "/show"
    end

    command "Jobs" do
      navigate_to "/jobs"
    end

    command "Theme", :open_theme_palette
    command "Close palette", :close_command_palette
    command "Quit app", :quit

    def current_route?(route)
      route.controller_class == self.class && route.action == :show
    end

    def sidebar_routes
      application.routes.all.uniq { |route| route.path }
    end

    def sidebar_index
      explicit_index = session[:sidebar_index]
      return explicit_index.clamp(0, [sidebar_routes.length - 1, 0].max) if explicit_index

      sidebar_routes.index { |route| current_route?(route) } || 0
    end

    private

    def sidebar_move(delta)
      count = sidebar_routes.length
      return render_default_action if count.zero?

      session[:sidebar_index] = (sidebar_index + delta).clamp(0, count - 1)
      render_default_action
    end

    def sidebar_select
      route = sidebar_routes[sidebar_index]
      if focus_ring_slot?(:content)
        focus.focus(:content)
      else
        session[:focus] = :content
      end
      route ? navigate_to(route.path) : render_default_action
    end
  end
end
