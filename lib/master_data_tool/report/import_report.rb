# frozen_string_literal: true

module MasterDataTool
  module Report
    class ImportReport
      include Core

      attr_reader :reports

      def print(printer)
        reports.each do |_, report|
          if report.is_a?(Array)
            report.each { |r| printer.print(convert_to_ltsv(r)) }
          else
            printer.print(convert_to_ltsv(report))
          end
        end
      end

      def reports
        @reports ||= count_report.merge(new_records_report, updated_records_report, no_change_records_report, deleted_records_report)
      end

      private

      def count_report
        label = :count_report
        {}.tap do |report|
          report[label] = []
          report[label] << {operation: :import, label: :count, table_name: master_data.table_name, before: master_data.before_count, after: master_data.after_count}
          report[label] << {operation: :import, label: :affected, table_name: master_data.table_name, affected: master_data.affected?}
          report[label] << {operation: :import, label: :new_count, table_name: master_data.table_name, count: master_data.new_records.count}
          report[label] << {operation: :import, label: :updated_count, table_name: master_data.table_name, count: master_data.updated_records.count}
          report[label] << {operation: :import, label: :no_change_count, table_name: master_data.table_name, count: master_data.no_change_records.count}
          report[label] << {operation: :import, label: :deleted_count, table_name: master_data.table_name, count: master_data.deleted_records.count}
        end
      end

      def new_records_report
        label = :new_records_report
        {}.tap do |report|
          report[label] = []
          master_data.new_records.each do |record|
            report[label] << {operation: :import, label: :detail, table_name: master_data.table_name, status: :new, id: record.id}
          end
        end
      end

      def updated_records_report
        label = :updated_records_report
        {}.tap do |report|
          report[label] = []
          master_data.updated_records.each do |record|
            report[label] << {operation: :import, label: :detail, table_name: master_data.table_name, status: :updated, id: record.id, detail: record.changes_to_save}
          end
        end
      end

      def no_change_records_report
        label = :no_change_records_report
        {}.tap do |report|
          report[label] = []
          master_data.no_change_records.each do |record|
            report[label] << {operation: :import, label: :detail, table_name: master_data.table_name, status: :no_change, id: record.id}
          end
        end
      end

      def deleted_records_report
        label = :deleted_records_report
        {}.tap do |report|
          report[label] = []
          master_data.deleted_records.each do |record|
            report[label] << {operation: :import, label: :detail, table_name: master_data.table_name, status: :deleted, id: record.id}
          end
        end
      end
    end
  end
end
