# frozen_string_literal: true

module MasterDataTool
  module Report
    class VerifyReport
      include Core

      attr_reader :reports

      def initialize(master_data:)
        super(master_data: master_data)
        @reports = []
      end

      def append(report:)
        @reports << report
      end

      def print(printer:)
        @reports.each do |report|
          printer.print(message: convert_to_ltsv(report))
        end
      end

      class << self
        def build_verify_record_report(master_data:, record:, valid:)
          { operation: :verify, table_name: master_data.table_name, valid: valid, id: record.id }
        end
      end
    end
  end
end
