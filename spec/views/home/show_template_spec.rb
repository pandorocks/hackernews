# frozen_string_literal: true

require "hackernews"

RSpec.describe "home/show template" do
  describe "#render" do
    it "renders the model title" do
      template = Charming::Presentation::Templates.resolve("home/show", root: Hackernews::Application.root)
      view = Charming::Presentation::TemplateView.new(
        template: template,
        namespace: Hackernews,
        home: Hackernews::HomeModel.new,
        screen: Charming::Screen.new(width: 80, height: 24),
        theme: Hackernews::Application.new.theme
      )

      expect(view.render).to include("Hackernews")
    end
  end
end
