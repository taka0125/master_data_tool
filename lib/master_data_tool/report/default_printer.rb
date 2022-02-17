# frozen_string_literal: true

module MasterDataTool
  module Report
    class DefaultPrinter
      include Printer

      def print(message)
        MasterDataTool.config.logger.info message
        puts message
      end
    end
  end
end
