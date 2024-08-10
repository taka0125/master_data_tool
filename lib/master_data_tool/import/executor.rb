# frozen_string_literal: true

module MasterDataTool
  module Import
    class Executor
      def initialize(spec_config:, import_config: nil, verify_config: nil,
                     dry_run: true, verify: true, silent: false,
                     override_identifier: nil, report_printer: nil)

        @spec_config = spec_config
        @import_config = import_config || MasterDataTool::Import::Config.default_config
        @verify_config = verify_config || MasterDataTool::Verify::Config.default_config

        @dry_run = dry_run
        @verify = verify
        @silent = silent

        @override_identifier = override_identifier
        @report_printer = report_printer || MasterDataTool::Report::DefaultPrinter.new(spec_config: spec_config)
        @report_printer.silent = silent

        @master_data_statuses_by_name = {}
      end

      def execute
        transaction do
          print_execute_options
          load_master_data_statuses

          master_data_collection = build_master_data_collection

          import_all!(master_data_collection)
          verify_all!(master_data_collection) if verify
          save_master_data_statuses!(master_data_collection)

          print_affected_tables(master_data_collection)

          raise DryRunError if dry_run

          master_data_collection
        end
      rescue DryRunError
        puts "[DryRun] end"
      end

      private

      attr_reader :master_data_statuses_by_name, :spec_config, :import_config, :verify_config,
                  :dry_run, :verify, :silent, :override_identifier, :report_printer

      def transaction
        spec_config.application_record_class.transaction do
          MasterDataTool::MasterDataStatus.transaction do
            yield
          end
        end
      end

      def print_execute_options
        return if silent

        puts "==== execute ===="
        instance_variables.each do |k|
          puts "#{k}: #{instance_variable_get(k).inspect}"
        end
        puts "================="
      end

      def build_master_data_collection
        MasterDataCollection.new.tap do |collection|
          MasterDataTool::MasterDataFileCollection.new(spec_name: spec_config.spec_name, override_identifier: override_identifier).each do |master_data_file|
            load_skip = load_skip_table?(master_data_file)
            master_data = MasterData.build(spec_config: spec_config, master_data_file: master_data_file, load: !load_skip)
            collection.append(master_data: master_data)
          end
        end
      end

      def import_all!(master_data_collection)
        master_data_collection.each do |master_data|
          next unless master_data.loaded?
          next if import_config.skip_table?(master_data.table_name)

          report = master_data.import!(import_config: import_config, dry_run: dry_run)
          report.print(printer: report_printer)
        end
      end

      def verify_all!(master_data_collection)
        master_data_collection.each do |master_data|
          next if verify_config.skip_table?(master_data.table_name)

          report = master_data.verify!(verify_config: verify_config, ignore_fail: dry_run)
          report.print(printer: report_printer)
        end
      end

      def save_master_data_statuses!(master_data_collection)
        records = []
        master_data_collection.each do |master_data|
          next unless master_data.loaded?

          records << MasterDataTool::MasterDataStatus.build(spec_name: spec_config.spec_name, master_data_file: master_data.master_data_file)
        end

        MasterDataTool::MasterDataStatus.import_records!(records: records, dry_run: dry_run)
      end

      def print_affected_tables(master_data_collection)
        master_data_collection.each do |master_data|
          next unless master_data.loaded?
          next unless master_data.affected?

          report = master_data.print_affected_table
          report&.print(printer: report_printer)
        end
      end

      def load_skip_table?(master_data_file)
        return true if import_config.skip_table?(master_data_file.table_name)
        return false unless import_config.skip_no_change

        master_data_status = master_data_statuses_by_name[master_data_file.table_name]
        return false unless master_data_status

        !master_data_status.will_change?(master_data_file)
      end

      def extract_master_data_csv_paths
        pattern = MasterDataTool.config.csv_dir_for(spec_name: spec_config.spec_name).join('*.csv').to_s
        Pathname.glob(pattern).select(&:file?)
      end

      def overridden_master_data_csv_paths
        return [] unless override_identifier

        pattern = MasterDataTool.config.csv_dir_for(spec_name: spec_config.spec_name, override_identifier: override_identifier).join('*.csv').to_s
        Pathname.glob(pattern).select(&:file?)
      end

      def load_master_data_statuses
        @master_data_statuses_by_name = MasterDataTool::MasterDataStatus.all.index_by(&:name)
      end
    end
  end
end
