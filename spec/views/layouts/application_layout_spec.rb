# frozen_string_literal: true

require "hackernews"

RSpec.describe Hackernews::Layouts::ApplicationLayout do
  let(:application) { Hackernews::Application.new }
  let(:controller) { Hackernews::HomeController.new(application: application) }
  let(:screen) { Charming::Screen.new(width: 80, height: 24) }
  let(:theme) { application.theme }

  def render_layout(**assigns)
    described_class.new(
      content: "Body content",
      screen: screen,
      controller: controller,
      theme: theme,
      **assigns
    ).render
  end

  it "renders the sidebar and yielded content" do
    plain = Charming::UI::Width.strip_ansi(render_layout)

    expect(plain).to include("Hackernews")
    expect(plain).to include("Top")
    expect(plain).to include("Body content")
  end

  it "renders the command palette as an overlay" do
    plain = Charming::UI::Width.strip_ansi(render_layout(palette: "Top\nNew"))

    expect(plain).to include("Command palette")
    expect(plain).to include("Type to filter. Enter selects. Escape closes.")
  end

  it "keeps separator rows blank while the selected story changes" do
    home = Hackernews::HomeModel.new
    home.story_ids_by_feed[home.feed] = (1..500).to_a
    home.stories_by_page[home.page_key] = Array.new(30) do |index|
      Hackernews::Story.new(
        id: index + 1,
        type: "story",
        by: "user",
        time: 0,
        title: "Story #{index + 1}",
        url: "https://example.com/#{index}",
        score: index,
        descendants: index,
        text: ""
      )
    end

    home.selected_index = 14
    frame = described_class.new(
      content: Hackernews::AppFrameComponent.new(home: home, screen: screen, theme: theme).render,
      screen: screen,
      controller: controller,
      theme: theme
    ).render
    plain_lines = Charming::UI::Width.strip_ansi(frame).lines(chomp: true)

    separator_row = plain_lines.find { |line| line.include?("│ │") && line !~ /Story|points|Hackernews|Top|New|Best|Ask|Show|Jobs|tab|commands|quit/ }
    expect(separator_row).not_to be_nil
  end
end
