# frozen_string_literal: true

require 'master_data_tool'
require 'database_cleaner/active_record'
require 'standalone_activerecord_boot_loader'

ENV['RAILS_ENV'] ||= 'test'

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

  def print(message)
    @io.puts message
  end
end

def build_master_data(path, override_identifier)
  f = MasterDataTool::MasterDataFile.build(path, override_identifier)
  MasterDataTool::MasterData.build(f)
end

DUMMY_APP_ROOT = Pathname.new(__dir__).join('dummy')

MasterDataTool.configure do |config|
  config.master_data_dir = DUMMY_APP_ROOT.join('db/fixtures')
end

instance = StandaloneActiverecordBootLoader::Instance.new(
  DUMMY_APP_ROOT,
  env: ENV['RAILS_ENV']
)
instance.execute

if ENV['CI']
  require 'simplecov'

  SimpleCov.start do
    %w[spec].each do |ignore_path|
      add_filter(ignore_path)
    end
  end
end
