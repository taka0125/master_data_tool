# frozen_string_literal: true

require 'master_data_tool'
require 'database_cleaner/active_record'
require_relative 'activerecord_helper'

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

MasterDataTool.configure do |config|
  config.master_data_dir = DUMMY_APP_ROOT.join('db/fixtures')
end

create_database_if_not_exists(env: ENV['RAILS_ENV'])

Time.zone = 'Tokyo'
ActiveRecord::Base.establish_connection(DATABASE_CONFIG[ENV['RAILS_ENV']])
ActiveRecord::Base.time_zone_aware_attributes = true

require DUMMY_APP_ROOT.join('app/models/application_record.rb')
DUMMY_APP_ROOT.glob('app/models/**/*.rb').each do |f|
  require f
end

# bundle exec ridgepole -c spec/dummy-common/config/database.yml --apply -f spec/dummy-common/db/Schemafile -E test
