# frozen_string_literal: true

require "hackernews"

RSpec.describe "home/show template" do
  describe "#render" do
    it "renders the model title" do
      template = Charming::Templates.resolve("home/show", root: Hackernews::Application.root)
      view = Charming::TemplateView.new(
        template: template,
        namespace: Hackernews,
        home: double(title: "Hackernews"),
        theme: Hackernews::Application.new.theme
      )

      expect(view.render).to include("Hackernews")
    end
  end
end
