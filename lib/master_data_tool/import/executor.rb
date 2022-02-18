# frozen_string_literal: true

module MasterDataTool
  module Import
    class Executor
      def initialize(dry_run: true, verify: true, only_import_tables: [], only_verify_tables: [], skip_no_change: true, silent: false, report_printer: MasterDataTool::Report::DefaultPrinter.new)
        @dry_run = dry_run
        @verify = verify
        @only_import_tables = Array(only_import_tables)
        @only_verify_tables = Array(only_verify_tables)
        @skip_no_change = skip_no_change
        @silent = silent
        @report_printer = report_printer
        @report_printer.silent = silent
      end

      def execute
        ApplicationRecord.transaction do
          master_data_list = build_master_data_list

          import_all!(master_data_list)
          verify_all!(master_data_list) if @verify
          save_master_data_statuses!(master_data_list)

          print_affected_tables(master_data_list)

          raise DryRunError if @dry_run

          master_data_list
        end
      rescue DryRunError
        puts "[DryRun] end"
      end

      private

      def build_master_data_list
        [].tap do |master_data_list|
          extract_master_data_csv_paths.each do |path|
            table_name = MasterDataTool.resolve_table_name(path)
            load_skip = load_skip_table?(table_name, path)

            model_klass = Object.const_get(table_name.classify)
            master_data = MasterData.new(path, model_klass)
            master_data.load unless load_skip

            master_data_list << master_data
          end
        end
      end

      # 1. 変更があるかどうかのチェックをスキップした
      # 2. 変更があるかどうかのチェックを実行し、変更がないので処理をスキップした
      # 3. 変更があるかどうかのチェックを実行し、変更があるので実行した
      # の3パターンがある
      def import_all!(master_data_list)
        master_data_list.each do |master_data|
          next unless master_data.loaded?

          report = master_data.import!(dry_run: @dry_run)
          report.print(@report_printer)
        end
      end

      def verify_all!(master_data_list)
        master_data_list.each do |master_data|
          next if verify_skip_table?(master_data.table_name)

          report = master_data.verify!(dry_run: @dry_run)
          report.print(@report_printer)
        end
      end

      def save_master_data_statuses!(master_data_list)
        records = []
        master_data_list.each do |master_data|
          records << MasterDataTool::MasterDataStatus.build(master_data.csv_path)
        end

        MasterDataTool::MasterDataStatus.import_records!(records, dry_run: @dry_run)
      end

      def print_affected_tables(master_data_list)
        master_data_list.each do |master_data|
          next unless master_data.loaded?
          next unless master_data.affected?

          report = master_data.print_affected_table
          report&.print(@report_printer)
        end
      end

      def load_skip_table?(table_name, csv_path)
        return load_skip_table_when_target_all_table?(table_name) unless @skip_no_change

        load_skip_table_when_target_changed_table?(table_name, csv_path)
      end

      def load_skip_table_when_target_changed_table?(table_name, csv_path)
        unless @only_import_tables.empty?
          return true if @only_import_tables.exclude?(table_name)
        end

        !MasterDataTool::MasterDataStatus.master_data_will_change?(csv_path)
      end

      def load_skip_table_when_target_all_table?(table_name)
        return false if @only_import_tables.empty?

        @only_import_tables.exclude?(table_name)
      end

      def verify_skip_table?(table_name)
        return false if @only_verify_tables.empty?

        @only_verify_tables.exclude?(table_name)
      end

      def extract_master_data_csv_paths
        pattern = Pathname.new(MasterDataTool.config.master_data_dir).join('*.csv').to_s
        Pathname.glob(pattern).select(&:file?)
      end
    end
  end
end
