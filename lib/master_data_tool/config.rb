module MasterDataTool
  class Config
    class_attribute :master_data_dir
    class_attribute :spec_configs

    def initialize
      self.master_data_dir = nil
      self.spec_configs = []
    end

    def spec_config(spec_name)
      spec_configs.detect { |c| c.spec_name.to_s == spec_name.to_s }
    end

    def csv_dir_for(spec_name:, override_identifier: nil)
      path = MasterDataTool.config.master_data_dir
      path = path.join(spec_name.to_s) if spec_name.present?
      path = path.join(override_identifier.to_s) if override_identifier.present?
      path
    end
  end
end
