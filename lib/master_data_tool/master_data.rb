# frozen_string_literal: true

module MasterDataTool
  module Import
    class MasterData
      attr_reader :csv_path, :model_klass, :columns, :new_records, :updated_records, :no_change_records, :deleted_records
      attr_reader :before_count, :after_count

      def initialize(csv_path, model_klass)
        @csv_path = csv_path
        @model_klass = model_klass

        @loaded = false

        @columns = []
        @new_records = []
        @updated_records = []
        @no_change_records = []
        @deleted_records = []
      end

      def load
        csv = CSV.read(@csv_path, headers: true, skip_blanks: true)
        old_records_by_id = @model_klass.all.index_by(&:id)

        csv_records_by_id = build_records_from_csv(csv, old_records_by_id)
        deleted_ids = old_records_by_id.keys - csv_records_by_id.keys

        @columns = csv.headers

        csv_records_by_id.each do |_, record|
          if record.new_record?
            @new_records << record

            next
          end

          if record.has_changes_to_save?
            @updated_records << record

            next
          end

          @no_change_records << record
        end

        deleted_ids.each do |id|
          @deleted_records << old_records_by_id[id]
        end

        @loaded = true
      end

      def import_records
        new_records + updated_records + no_change_records
      end

      def affected_records
        new_records + updated_records + deleted_records
      end

      def new_records
        raise MasterDataTool::NotLoadedError unless @loaded

        @new_records
      end

      def updated_records
        raise MasterDataTool::NotLoadedError unless @loaded

        @updated_records
      end

      def no_change_records
        raise MasterDataTool::NotLoadedError unless @loaded

        @no_change_records
      end

      def deleted_records
        raise MasterDataTool::NotLoadedError unless @loaded

        @deleted_records
      end

      def loaded?
        @loaded
      end

      def affected?
        return @affected if instance_variable_defined?(:@affected)
        @affected = affected_records.any?
      end

      def before_count
        @before_count ||= updated_records.count + no_change_records.count + deleted_records.count
      end

      def after_count
        @after_count ||= updated_records.count + no_change_records.count + new_records.count
      end

      def table_name
        @model_klass.table_name
      end

      def import!(dry_run: true)
        raise MasterDataTool::NotLoadedError unless @loaded

        MasterDataTool::Report::ImportReport.new(self).tap do |report|
          return report if dry_run
          return report unless affected?

          @model_klass.delete_all

          # マスターデータ間の依存がある場合に投入順制御するのは大変なのでこのタイミングでのバリデーションはしない
          @model_klass.import(import_records, validate: false, on_duplicate_key_update: @columns, timestamps: true)
        end
      end

      def verify!(dry_run: true)
        MasterDataTool::Report::VerifyReport.new(self).tap do |report|
          @model_klass.all.find_each do |record|
            valid = record.valid?
            report.append(MasterDataTool::Report::VerifyReport.build_verify_record_report(self, record, valid))
            next if dry_run

            raise MasterDataTool::VerifyFailed.new("[#{table_name}] id = #{record.id} is invalid") unless valid
          end
        end
      end

      def print_affected_table
        return unless loaded?
        return unless affected?

        MasterDataTool::Report::PrintAffectedTableReport.new(self)
      end

      private

      def build_records_from_csv(csv, old_records_by_id)
        {}.tap do |records|
          csv.each do |row|
            id = row['id'].to_i
            record = old_records_by_id[id] || @model_klass.new(id: id)

            csv.headers.each do |key|
              record[key.to_s] = row[key]
            end

            records[id] = record
          end
        end
      end
    end
  end
end
