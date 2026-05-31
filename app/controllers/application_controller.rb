# frozen_string_literal: true

module Hackernews
  class ApplicationController < Charming::Controller
    layout "layouts/application"
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
  end
end
