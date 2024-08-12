# frozen_string_literal: true

module MasterDataTool
  module Report
    class PrintAffectedTableReport
      include Core

      def print(printer:)
        printer.print(message: convert_to_ltsv({ operation: :affected_table, table_name: master_data.table_name }))
      end
    end
  end
end
