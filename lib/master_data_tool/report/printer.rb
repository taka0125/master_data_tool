# frozen_string_literal: true

module MasterDataTool
  module Report
    module Printer
      attr_accessor :silent

      def initialize(silent: false)
        @silent = silent
      end

      def print(message)
        return if @silent

        raise NotImplementedError
      end
    end
  end
end
