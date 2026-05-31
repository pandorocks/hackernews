# frozen_string_literal: true

require "hackernews"

RSpec.describe Hackernews::HomeController do
  let(:application) { Hackernews::Application.new }
  let(:executor) do
    Class.new do
      attr_reader :submitted

      def submit(name, &block)
        @submitted = [name, block]
      end
    end.new
  end

  subject(:controller) { described_class.new(application: application) }

  before do
    application.task_executor = executor
  end

  describe "#show" do
    it "renders the shell before the feed task finishes" do
      response = controller.dispatch(:show)

      expect(response).to respond_to(:body)
      expect(response.body).to include("Loading Top Stories")
      expect(executor.submitted.first).to eq(:load_feed)
    end
  end

  describe "#new" do
    it "switches feed routes while keeping the home view" do
      response = controller.dispatch(:new)

      expect(response.body).to include("Hackernews / New")
    end
  end

  describe "#sidebar_index" do
    it "respects manual sidebar movement instead of snapping to the active feed" do
      controller.dispatch(:show)
      application.session[:sidebar_index] = 2

      expect(controller.sidebar_index).to eq(2)
    end
  end

  describe "#load_feed_done" do
    it "clears loading state when the current page finishes loading" do
      home = application.session[:models] = {home: Hackernews::HomeModel.new}
      model = home.fetch(:home)
      model.loading = true
      model.loading_key = "stale"
      event = Charming::TaskEvent.new(
        name: :load_feed,
        value: {feed: "top", page: 0, ids: [1], stories: []}
      )

      described_class.new(application: application, event: event).dispatch(:load_feed_done)

      expect(model.loading).to be(false)
      expect(model.loading_key).to be_nil
    end
  end
end
