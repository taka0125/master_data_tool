# frozen_string_literal: true

module MasterDataTool
  class MasterDataCollection
    def initialize
      @collection = []
    end

    def append(master_data:)
      @collection << master_data
    end

    def each
      return enum_for(:each) unless block_given?

      @collection.sort_by(&:basename).each do |master_data|
        yield master_data
      end
    end

    def to_a
      each.to_a
    end
  end
end
