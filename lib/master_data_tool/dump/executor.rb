# frozen_string_literal: true

module MasterDataTool
  module Dump
    class Executor
      Error = Struct.new(:table, :exception)

      DEFAULT_IGNORE_TABLES = %w[ar_internal_metadata schema_migrations master_data_statuses]
      DEFAULT_IGNORE_COLUMNS = %w[created_at updated_at]

      def initialize(spec_config:, ignore_empty_table: true, ignore_tables: [], ignore_column_names: [], only_tables: [], verbose: false)
        @spec_config = spec_config
        @ignore_empty_table = ignore_empty_table
        @ignore_tables = DEFAULT_IGNORE_TABLES + Array(spec_config.dump_ignore_tables) + ignore_tables
        @ignore_column_names = DEFAULT_IGNORE_COLUMNS + Array(spec_config.dump_ignore_columns) + ignore_column_names
        @only_tables = Array(only_tables)
        @verbose = verbose
      end

      def execute
        [].tap do |errors|
          spec_config.application_record_class.connection.tables.each do |table|
            if ignore_tables.include?(table)
              print_message "[ignore] #{table}"

              next
            end

            if only_tables.any? && !only_tables.include?(table)
              print_message "[skip] #{table}"
              next
            end

            dump_to_csv(table)
          rescue => e
            errors << Error.new(table, e)
          end
        end
      end

      private

      attr_reader :spec_config, :ignore_empty_table, :ignore_tables, :ignore_column_names, :only_tables, :verbose

      def print_message(message)
        return unless verbose

        puts message
      end

      def dump_to_csv(table)
        model_klass = Object.const_get(table.classify)
        if ignore?(model_klass)
          print_message "[ignore] #{table}"

          return
        end

        csv_path = MasterDataTool.config.csv_dir_for(spec_config.spec_name).join("#{table}.csv")
        FileUtils.mkdir_p(csv_path.dirname)

        CSV.open(csv_path, 'w', force_quotes: true) do |csv|
          headers = model_klass.column_names - ignore_column_names

          csv << headers

          model_klass.all.find_each do |record|
            items = []
            headers.each do |name|
              items << record[name]
            end

            csv << items
          end
        end
      end

      def ignore?(model_klass)
        return false unless ignore_empty_table

        model_klass.count < 1
      end
    end
  end
end
