# frozen_string_literal: true

require 'csv'
require_relative "master_data_tool/version"
require_relative "master_data_tool/config"
require_relative "master_data_tool/master_data_status"
require_relative "master_data_tool/master_data"
require_relative "master_data_tool/report"
require_relative "master_data_tool/dump/executor"
require_relative "master_data_tool/import"

module MasterDataTool
  class Error < StandardError; end
  class DryRunError < StandardError; end
  class VerifyFailed < StandardError; end
  class NotLoadedError < StandardError; end

  class << self
    def config
      @config ||= Config.default_config
    end

    def configure
      yield config
    end

    def resolve_table_name(csv_path)
      # 0001_table_nameのように投入順序を制御可能にする
      csv_path.relative_path_from(config.master_data_dir).to_s.gsub(/^\d+_/, '').delete_suffix('.csv')
    end
  end
end
