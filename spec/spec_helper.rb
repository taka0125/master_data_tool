# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../spec/dummy/config/environment", __FILE__)
require "rspec/rails"
require "master_data_tool"

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
