# frozen_string_literal: true

module MasterDataTool
  module Report
    class PrintAffectedTableReport
      include Core

      def initialize(master_data)
        super(master_data)
        @reports = []
      end

      def print(printer)
        printer.print(convert_to_ltsv({operation: :affected_table, table_name: @master_data.table_name}))
      end
    end
  end
end
