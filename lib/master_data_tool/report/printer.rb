# frozen_string_literal: true

module MasterDataTool
  module Report
    module Printer
      attr_reader :spec_config
      attr_accessor :silent

      def initialize(spec_config:, silent: false)
        @spec_config = spec_config
        @silent = silent
      end

      def print(message:)
        return if silent

        raise NotImplementedError
      end
    end
  end
end
