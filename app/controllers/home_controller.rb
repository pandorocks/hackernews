# frozen_string_literal: true

module Hackernews
  class HomeController < ApplicationController

    def show
      render :show, home: home, palette: command_palette
    end


    private
    def home
      model(:home, HomeModel)
    end
  end
end
