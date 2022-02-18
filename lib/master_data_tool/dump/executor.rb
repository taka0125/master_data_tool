# frozen_string_literal: true

module MasterDataTool
  module Dump
    class Executor
      Error = Struct.new(:table, :exception)

      DEFAULT_IGNORE_TABLES = %w[ar_internal_metadata schema_migrations master_data_statuses]
      DEFAULT_IGNORE_COLUMNS = %w[created_at updated_at]

      def initialize(ignore_empty_table: true, ignore_tables: [], ignore_column_names: [], verbose: false)
        @ignore_empty_table = ignore_empty_table
        @ignore_tables = DEFAULT_IGNORE_TABLES + Array(MasterDataTool.config.dump_ignore_tables) + ignore_tables
        @ignore_column_names = DEFAULT_IGNORE_COLUMNS + Array(MasterDataTool.config.dump_ignore_columns) + ignore_column_names
      end

      def execute
        [].tap do |errors|
          ApplicationRecord.connection.tables.each do |table|
            if @ignore_tables.include?(table)
              print_message "[ignore] #{table}"

              next
            end

            dump_to_csv(table)
          rescue => e
            errors << Error.new(table, e)
          end
        end
      end

      private

      def print_message(message)
        return unless @verbose

        puts message
      end

      def dump_to_csv(table)
        model_klass = Object.const_get(table.classify)
        if ignore?(model_klass)
          print_message "[ignore] #{table}"

          return
        end

        csv_path = Pathname.new(MasterDataTool.config.master_data_dir).join("#{table}.csv")
        CSV.open(csv_path, 'w', force_quotes: true) do |csv|
          headers = model_klass.column_names - @ignore_column_names

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
        return false unless @ignore_empty_table

        model_klass.count < 1
      end
    end
  end
end
