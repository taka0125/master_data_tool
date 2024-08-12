module MasterDataTool
  module Command
    module Dump
      extend ActiveSupport::Concern

      included do
        desc 'dump', 'dump'

        option :spec_name, default: nil, type: :string

        option :ignore_empty_table, default: MasterDataTool::Dump::Config::DEFAULT_VALUES[:ignore_empty_table], type: :boolean
        option :ignore_tables, default: MasterDataTool::Dump::Config::DEFAULT_VALUES[:ignore_tables], type: :array
        option :ignore_column_names, default: MasterDataTool::Dump::Config::DEFAULT_VALUES[:ignore_column_names], type: :array
        option :only_tables, default: MasterDataTool::Dump::Config::DEFAULT_VALUES[:only_tables], type: :array
        option :verbose, default: false, type: :boolean

        def dump
          spec_config = MasterDataTool.config.spec_config(options[:spec_name])
          raise "正しいspec_nameを指定して下さい" unless spec_config

          dump_config = spec_config.dump_config || MasterDataTool::Dump::Config.new(
            ignore_empty_table: options[:ignore_empty_table],
            ignore_tables: options[:ignore_tables],
            ignore_column_names: options[:ignore_column_names],
            only_tables: options[:only_tables]
          )

          executor = MasterDataTool::Dump::Executor.new(
            spec_config: spec_config,
            dump_config: dump_config,
            verbose: options[:verbose]
          )
          errors = executor.execute

          return if errors.empty?

          message = errors.map { |error| "table:#{error.table}\tmessage:#{error.exception.message}" }.join("\n")
          raise message
        end
      end
    end
  end
end
