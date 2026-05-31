# frozen_string_literal: true

require "charming"
require "zeitwerk"

module Hackernews
end

loader = Zeitwerk::Loader.new
loader.tag = "hackernews"
loader.inflector.inflect("version" => "VERSION")
loader.push_dir(File.expand_path("hackernews", __dir__), namespace: Hackernews)
loader.push_dir(File.expand_path("../app/models", __dir__), namespace: Hackernews)
loader.push_dir(File.expand_path("../app/components", __dir__), namespace: Hackernews)
loader.push_dir(File.expand_path("../app/views", __dir__), namespace: Hackernews)
loader.push_dir(File.expand_path("../app/controllers", __dir__), namespace: Hackernews)
loader.setup

require_relative "../config/routes"
