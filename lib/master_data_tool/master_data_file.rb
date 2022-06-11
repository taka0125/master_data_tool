# frozen_string_literal: true
module MasterDataTool
  class MasterDataFile < Struct.new(:table_name, :path, :override_identifier)
    def initialize(table_name, path, override_identifier)
      super(table_name, path, override_identifier)
      freeze
    end

    def basename
      self.path.basename
    end
  end
end
