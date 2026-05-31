# frozen_string_literal: true

Hackernews::Application.routes do
  root "home#show", title: "Top"
  screen "/new", to: "home#new", title: "New"
  screen "/best", to: "home#best", title: "Best"
  screen "/ask", to: "home#ask", title: "Ask HN"
  screen "/show", to: "home#show_hn", title: "Show HN"
  screen "/jobs", to: "home#jobs", title: "Jobs"
end
