module MasterDataTool
  module Verify
    class Config
      DEFAULT_VALUES = {
        only_tables: [],
        except_tables: [],
        preload_belongs_to_associations: true,
        preload_associations: {},
        eager_load_associations: {}
      }

      attr_accessor :only_tables, :except_tables, :preload_belongs_to_associations,
                    :preload_associations,  # key: Class, value: associations
                    :eager_load_associations # key: Class, value: associations

      def initialize(only_tables:, except_tables:, preload_belongs_to_associations:, preload_associations:, eager_load_associations:)
        @only_tables = only_tables
        @except_tables = except_tables
        @preload_belongs_to_associations = preload_belongs_to_associations
        @preload_associations = preload_associations
        @eager_load_associations = eager_load_associations
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
