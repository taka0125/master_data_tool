require 'active_support/configurable'

module MasterDataTool
  class Config
    include ActiveSupport::Configurable

    config_accessor :master_data_dir
    config_accessor :dump_ignore_tables
    config_accessor :dump_ignore_columns
    config_accessor :logger

    def self.default_config
      new.tap do |config|
        config.master_data_dir = nil # Rails.root.join('db/fixtures')
        config.dump_ignore_tables = %w[]
        config.dump_ignore_columns = %w[]
        config.logger = Logger.new(nil)
      end
    end
  end
end
