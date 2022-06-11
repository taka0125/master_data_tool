# frozen_string_literal: true
module MasterDataTool
  class MasterDataFile
    attr_reader :table_name, :path, :override_identifier

    def initialize(table_name, path, override_identifier)
      @table_name = table_name
      @path = path
      @override_identifier = override_identifier
      freeze
    end

    class << self
      def build(path, override_identifier)
        table_name = MasterDataTool.resolve_table_name(path, override_identifier)
        new(table_name, path, override_identifier)
      end
    end

    def basename
      @path.basename
    end

    def ==(other)
      other.class === self &&
        other.hash == hash
    end

    alias eql? ==

    def hash
      [@table_name, @path, @override_identifier].join.hash
    end
  end
end
