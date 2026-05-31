# frozen_string_literal: true

module Hackernews
  class HomeModel < ApplicationModel
    attribute :title, :string, default: "Hackernews"
  end
end
