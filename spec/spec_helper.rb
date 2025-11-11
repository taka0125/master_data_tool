# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

if ENV['CI']
  require 'simplecov'
  require 'simplecov_json_formatter'
  SimpleCov.start do
    formatter SimpleCov::Formatter::MultiFormatter.new([
                                                         SimpleCov::Formatter::JSONFormatter,
                                                         SimpleCov::Formatter::HTMLFormatter
                                                       ])
    add_filter '/spec/'
  end
end

require 'master_data_tool'
require 'database_cleaner/active_record'
require 'standalone_activerecord_boot_loader'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

class DebugPrinter
  include MasterDataTool::Report::Printer

  def initialize(io)
    @io = io
  end

  def print(message:)
    @io.puts message
  end
end

def build_master_data(spec_name, path, override_identifier)
  f = MasterDataTool::MasterDataFile.build(spec_name: spec_name, path: path, override_identifier: override_identifier)
  MasterDataTool::MasterData.build(spec_config: build_spec_config(spec_name), master_data_file: f)
end

def build_spec_config(spec_name, preload_associations: {}, eager_load_associations: {})
  verify_config = MasterDataTool::Verify::Config.default_config.configure do |c|
    c.preload_associations = preload_associations
    c.eager_load_associations = eager_load_associations
  end

  MasterDataTool::SpecConfig.new(
    spec_name: spec_name, application_record_class: ::ApplicationRecord,
    import_config: MasterDataTool::Import::Config.default_config,
    verify_config: verify_config,
    dump_config: MasterDataTool::Dump::Config.default_config
  )
end

require 'single_database_helper'
