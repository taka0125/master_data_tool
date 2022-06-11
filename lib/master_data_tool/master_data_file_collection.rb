# frozen_string_literal: true

module MasterDataTool
  class MasterDataFileCollection
    def initialize(override_identifier: nil)
      @override_identifier = override_identifier
      @collection = build
      freeze
    end

    def each
      return enum_for(:each) unless block_given?

      @collection.each do |file|
        yield file
      end
    end

    def to_a
      each.to_a
    end

    private

    def build
      files = extract_master_data_csv_paths.presence&.index_by(&:table_name)
      overridden_files = overridden_master_data_csv_paths.presence&.index_by(&:table_name) || {}

      table_names = (files.keys + overridden_files.keys).uniq
      table_names.map do |table_name|
        overridden_files[table_name] || files[table_name]
      end
    end

    def extract_master_data_csv_paths
      pattern = Pathname.new(MasterDataTool.config.master_data_dir).join('*.csv').to_s
      Pathname.glob(pattern).select(&:file?).map do |path|
        MasterDataFile.build(path, nil)
      end
    end

    def overridden_master_data_csv_paths
      return [] if @override_identifier.blank?

      pattern = Pathname.new(MasterDataTool.config.master_data_dir).join(@override_identifier).join('*.csv').to_s
      Pathname.glob(pattern).select(&:file?).map do |path|
        MasterDataFile.build(path, @override_identifier)
      end
    end
  end
end
