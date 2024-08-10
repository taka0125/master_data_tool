# frozen_string_literal: true

module MasterDataTool
  module Verify
    class Executor
      def initialize(spec_config:, verify_config: nil, silent: false, override_identifier: nil, report_printer: nil)
        @spec_config = spec_config
        @verify_config = verify_config || MasterDataTool::Verify::Config.default_config
        @silent = silent
        @override_identifier = override_identifier
        @report_printer = report_printer || MasterDataTool::Report::DefaultPrinter.new(spec_config: spec_config)
        @report_printer.silent = silent
      end

      def execute
        master_data_collection = build_master_data_collection
        master_data_collection.each do |master_data|
          next if verify_config.skip_table?(master_data.table_name)

          report = master_data.verify!(verify_config: verify_config, ignore_fail: false)
          report.print(printer: report_printer)
        end
      end

      private

      attr_reader :spec_config, :verify_config, :silent, :override_identifier, :report_printer

      def build_master_data_collection
        MasterDataCollection.new.tap do |collection|
          MasterDataTool::MasterDataFileCollection.new(spec_name: spec_config.spec_name, override_identifier: override_identifier).each do |master_data_file|
            master_data = MasterData.build(spec_config: spec_config, master_data_file: master_data_file, load: true)
            collection.append(master_data: master_data)
          end
        end
      end
    end
  end
end
