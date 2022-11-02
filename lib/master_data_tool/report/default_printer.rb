# frozen_string_literal: true

module MasterDataTool
  module Report
    class DefaultPrinter
      include Printer

      def print(message)
        return if silent
        return if message.blank?

        spec_config.logger.info message
        puts message
      end
    end
  end
end
