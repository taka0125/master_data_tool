require 'active_support/configurable'

module MasterDataTool
  class Config
    include ActiveSupport::Configurable

    config_accessor :master_data_dir
    config_accessor :dump_ignore_tables
    config_accessor :dump_ignore_columns
    config_accessor :default_import_options
    config_accessor :logger

    def initialize
      self.master_data_dir = nil
      self.dump_ignore_tables = %w[]
      self.dump_ignore_columns = %w[]
      self.default_import_options = {}
      self.logger = Logger.new(nil)
    end
  end
end
