module MasterDataTool
  class SpecConfig
    attr_reader :spec_name, :application_record_class, :dump_ignore_tables, :dump_ignore_columns,
                :default_import_options, :logger, :preload_associations, :eager_load_associations

    def initialize(spec_name:, application_record_class:, dump_ignore_tables: [], dump_ignore_columns: [],
                   default_import_options: {}, logger: Logger.new(nil), preload_associations: {}, eager_load_associations: {})

      @spec_name = spec_name.presence || ''
      @application_record_class = application_record_class
      @dump_ignore_tables = dump_ignore_tables
      @dump_ignore_columns = dump_ignore_columns
      @default_import_options = default_import_options
      @logger = logger
      @preload_associations = preload_associations # key: Class, value: associations
      @eager_load_associations = eager_load_associations # key: Class, value: associations

      freeze
    end
  end
end
