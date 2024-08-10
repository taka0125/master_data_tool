module MasterDataTool
  module Import
    class Config
      DEFAULT_VALUES = {
        only_tables: [],
        except_tables: [],
        skip_no_change: true,
        ignore_foreign_key_when_delete: true,
      }

      attr_accessor :only_tables, :except_tables, :skip_no_change, :ignore_foreign_key_when_delete

      def initialize(only_tables:, except_tables:, skip_no_change:, ignore_foreign_key_when_delete:)
        @only_tables = only_tables
        @except_tables = except_tables
        @skip_no_change = skip_no_change
        @ignore_foreign_key_when_delete = ignore_foreign_key_when_delete
      end

      def skip_table?(table_name)
        MasterDataTool.need_skip_table?(table_name, only_tables, except_tables)
      end

      def configure
        yield self
      end

      class << self
        def default_config
          new(**DEFAULT_VALUES)
        end
      end
    end
  end
end
