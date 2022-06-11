# frozen_string_literal: true

require 'csv'
require_relative "master_data_tool/version"
require_relative "master_data_tool/config"
require_relative "master_data_tool/master_data_status"
require_relative "master_data_tool/master_data_file"
require_relative "master_data_tool/master_data_file_collection"
require_relative "master_data_tool/master_data"
require_relative "master_data_tool/master_data_collection"
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
      @config ||= Config.new
    end

    def configure
      yield config
    end

    def resolve_table_name(csv_path, override_identifier)
      # 0001_table_nameのように投入順序を制御可能にする
      relative_path = config.master_data_dir
      relative_path = "#{relative_path}/#{override_identifier}" if override_identifier.present?
      csv_path.relative_path_from(relative_path).to_s.gsub(/^\d+_/, '').delete_suffix('.csv')
    end
  end
end
