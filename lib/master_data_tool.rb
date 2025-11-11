# frozen_string_literal: true

require 'csv'
require 'socket'
require 'active_support'
require 'active_support/core_ext'
require_relative "master_data_tool/version"
require_relative "master_data_tool/act_as_master_data"
require_relative "master_data_tool/config"
require_relative "master_data_tool/spec_config"
require_relative "master_data_tool/master_data_status"
require_relative "master_data_tool/master_data_file"
require_relative "master_data_tool/master_data_file_collection"
require_relative "master_data_tool/master_data"
require_relative "master_data_tool/master_data_collection"
require_relative "master_data_tool/report"
require_relative "master_data_tool/dump"
require_relative "master_data_tool/import"
require_relative "master_data_tool/verify"
require_relative "master_data_tool/command"

module MasterDataTool
  class Error < StandardError; end
  class DryRunError < StandardError; end
  class NotLoadedError < StandardError; end

  class VerifyFailed < StandardError
    attr_accessor :errors
    delegate :full_messages, to: :errors
  end

  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end

    def resolve_table_name(spec_name:, csv_path:, override_identifier:)
      # 0001_table_nameのように投入順序を制御可能にする
      relative_path = MasterDataTool.config.csv_dir_for(spec_name: spec_name, override_identifier: override_identifier)
      csv_path.relative_path_from(relative_path).to_s.gsub(/^\d+_/, '').delete_suffix('.csv')
    end

    # 1. onlyを指定した時点でそのリストに含まれるものだけになるべき
    # 2. exceptのリストはどんな状況でも除外されるべき
    # 3. それ以外はすべて実行する
    def need_skip_table?(table_name, only, except)
      only_result = only.presence&.include?(table_name)
      except_result = except.presence&.include?(table_name)

      # onlyが指定された時点でデフォルトはskipとする
      default = only_result.nil? ? false : true
      return true if except_result == true
      return false if only_result == true

      default
    end
  end
end
