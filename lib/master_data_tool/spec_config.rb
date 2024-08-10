module MasterDataTool
  class SpecConfig
    attr_accessor :spec_name, :application_record_class, :import_config, :verify_config, :dump_config, :logger

    def initialize(spec_name:, application_record_class:, import_config: nil, verify_config: nil, dump_config: nil, logger: Logger.new(nil))

      @spec_name = spec_name.presence || ''
      @application_record_class = application_record_class
      @import_config = import_config
      @verify_config = verify_config
      @dump_config = dump_config
      @logger = logger
    end

    def configure
      yield self
    end
  end
end
