module MasterDataTool
  module Dump
    class Config
      DEFAULT_IGNORE_TABLES = %w[ar_internal_metadata schema_migrations master_data_statuses]
      DEFAULT_IGNORE_COLUMNS = %w[created_at updated_at]

      DEFAULT_VALUES = {
        ignore_empty_table: true,
        ignore_tables: [],
        ignore_column_names: [],
        only_tables: [],
      }

      attr_accessor :ignore_empty_table, :ignore_tables, :ignore_column_names, :only_tables

      def initialize(ignore_empty_table:, ignore_tables:, ignore_column_names:, only_tables:)
        @ignore_empty_table = ignore_empty_table
        @ignore_tables = DEFAULT_IGNORE_TABLES + ignore_tables
        @ignore_column_names = DEFAULT_IGNORE_COLUMNS + ignore_column_names
        @only_tables = only_tables
      end

      def configure
        yield self
      end

      def ignore_tables=(tables)
        @ignore_tables = (DEFAULT_IGNORE_TABLES + tables).uniq
      end

      def ignore_column_names=(column_names)
        @ignore_column_names = (DEFAULT_IGNORE_COLUMNS + column_names).uniq
      end

      class << self
        def default_config
          new(**DEFAULT_VALUES)
        end
      end
    end
  end
end
