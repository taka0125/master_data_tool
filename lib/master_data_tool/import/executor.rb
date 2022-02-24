# frozen_string_literal: true

module MasterDataTool
  module Import
    class Executor
      def initialize(dry_run: true,
                     verify: true,
                     only_import_tables: [],
                     except_import_tables: [],
                     only_verify_tables: [],
                     except_verify_tables: [],
                     skip_no_change: true,
                     silent: false,
                     report_printer: MasterDataTool::Report::DefaultPrinter.new)

        @dry_run = dry_run
        @verify = verify
        @only_import_tables = Array(only_import_tables)
        @except_import_tables = Array(except_import_tables)
        @only_verify_tables = Array(only_verify_tables)
        @except_verify_tables = Array(except_verify_tables)
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
        end.sort_by { |m| m.csv_path } # 外部キー制約などがある場合には先に入れておかないといけないデータなどがある。なので、プレフィックスを付けて順序を指定して貰う
      end

      def import_all!(master_data_list)
        master_data_list.each do |master_data|
          next unless master_data.loaded?
          next if import_skip_table?(master_data.table_name)

          report = master_data.import!(dry_run: @dry_run)
          report.print(@report_printer)
        end
      end

      def verify_all!(master_data_list)
        master_data_list.each do |master_data|
          next if verify_skip_table?(master_data.table_name)

          report = master_data.verify!(ignore_fail: @dry_run)
          report.print(@report_printer)
        end
      end

      def save_master_data_statuses!(master_data_list)
        records = []
        master_data_list.each do |master_data|
          next unless master_data.loaded?

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
        return true if import_skip_table?(table_name)
        return false unless @skip_no_change

        !MasterDataTool::MasterDataStatus.master_data_will_change?(csv_path)
      end

      def import_skip_table?(table_name)
        need_skip_table?(table_name, @only_import_tables, @except_import_tables)
      end

      def verify_skip_table?(table_name)
        need_skip_table?(table_name, @only_verify_tables, @except_verify_tables)
      end

      # 1. onlyを指定した時点でそのリストに含まれるものだけになるべき
      # 2. exceptのリストはどんな状況でも除外されるべき
      # 3. それ以外はすべて実行する
      def need_skip_table?(table_name, only, except)
        only_result = only.presence&.include?(table_name)
        except_result = except.presence&.include?(table_name)

        # onlyが指定された時点でデフォルトはskipとする
        default = only_result.nil? ? false : true
        return true if except_result == true
        return false if only_result == true

        default
      end

      def extract_master_data_csv_paths
        pattern = Pathname.new(MasterDataTool.config.master_data_dir).join('*.csv').to_s
        Pathname.glob(pattern).select(&:file?)
      end
    end
  end
end
