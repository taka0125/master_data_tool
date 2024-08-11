# frozen_string_literal: true

module MasterDataTool
  module Report
    module Core
      attr_reader :master_data

      def initialize(master_data:)
        @master_data = master_data
      end

      def print(printer:)
        raise NotImplementedError
      end

      private

      def convert_to_ltsv(items)
        items.map { |k, v| "#{k}:#{v}" }.join("\t")
      end
    end
  end
end
