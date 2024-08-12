# frozen_string_literal: true

module MasterDataTool
  class MasterData
    BULK_INSERT_SIZE = 1000

    attr_reader :master_data_file, :model_klass, :columns, :spec_config

    def initialize(spec_config:, master_data_file:, model_klass:)
      @spec_config = spec_config
      @master_data_file = master_data_file
      @model_klass = model_klass

      @loaded = false
      @columns = []
      @new_records = []
      @updated_records = []
      @no_change_records = []
      @deleted_records = []
    end

    class << self
      def build(spec_config:, master_data_file:, load: false)
        model_klass = Object.const_get(master_data_file.table_name.classify)
        new(spec_config: spec_config, master_data_file: master_data_file, model_klass: model_klass).tap do |record|
          record.load if load
        end
      end
    end

    def basename
      master_data_file.basename
    end

    def load
      csv = CSV.read(master_data_file.path, headers: true, skip_blanks: true)
      old_records_by_id = model_klass.all.index_by(&:id)

      csv_records_by_id = build_records_from_csv(csv, old_records_by_id)
      deleted_ids = old_records_by_id.keys - csv_records_by_id.keys

      self.columns = csv.headers

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
      raise MasterDataTool::NotLoadedError unless loaded?

      @new_records
    end

    def updated_records
      raise MasterDataTool::NotLoadedError unless loaded?

      @updated_records
    end

    def no_change_records
      raise MasterDataTool::NotLoadedError unless loaded?

      @no_change_records
    end

    def deleted_records
      raise MasterDataTool::NotLoadedError unless loaded?

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
      model_klass.table_name
    end

    def import!(import_config:, dry_run: true)
      raise MasterDataTool::NotLoadedError unless loaded?

      ignore_foreign_key_when_delete = import_config.ignore_foreign_key_when_delete

      MasterDataTool::Report::ImportReport.new(master_data: self).tap do |report|
        return report if dry_run
        return report unless affected?

        disable_foreign_key_checks if ignore_foreign_key_when_delete
        model_klass.delete_all
        enable_foreign_key_checks if ignore_foreign_key_when_delete

        import_records.each_slice(BULK_INSERT_SIZE) do |chunked_import_records|
          records = chunked_import_records.map { |obj| obj.attributes.slice(*columns) }
          model_klass.insert_all(records)
        end
      end
    end

    def verify!(verify_config:, ignore_fail: false)
      MasterDataTool::Report::VerifyReport.new(master_data: self).tap do |report|
        preload_associations = decide_preload_associations(verify_config)
        eager_load_associations = decide_eager_load_associations(verify_config)

        scoped = model_klass.all
        scoped = scoped.preload(preload_associations) unless preload_associations.empty?
        scoped = scoped.eager_load(eager_load_associations) unless eager_load_associations.empty?

        scoped.find_each do |record|
          valid = record.valid?
          report.append(report: MasterDataTool::Report::VerifyReport.build_verify_record_report(master_data: self, record: record, valid: valid))

          next if valid
          next if ignore_fail

          e = MasterDataTool::VerifyFailed.new("[#{table_name}] id = #{record.id} is invalid")
          e.errors = record.errors

          raise e
        end
      end
    end

    def print_affected_table
      return unless loaded?
      return unless affected?

      MasterDataTool::Report::PrintAffectedTableReport.new(master_data: self)
    end

    private

    attr_writer :loaded, :columns, :new_records, :updated_records,
                :no_change_records, :deleted_records

    def decide_preload_associations(verify_config)
      preload_associations = model_klass.reflections.values.select(&:belongs_to?).map(&:name).map(&:to_sym) if verify_config.preload_belongs_to_associations
      preload_associations += verify_config.preload_associations.dig(model_klass.to_s.to_sym)&.map(&:to_sym) || []
      preload_associations.uniq
    end

    def decide_eager_load_associations(verify_config)
      verify_config.eager_load_associations.dig(model_klass.to_s.to_sym)&.map(&:to_sym) || []
    end

    def build_records_from_csv(csv, old_records_by_id)
      {}.tap do |records|
        csv.each do |row|
          id = row['id'].to_i
          record = old_records_by_id[id] || model_klass.new(id: id)

          csv.headers.each do |key|
            record[key.to_s] = row[key]
          end

          records[id] = record
        end
      end
    end

    def enable_foreign_key_checks
      spec_config.application_record_class.connection.execute('SET FOREIGN_KEY_CHECKS = 1')
    end

    def disable_foreign_key_checks
      spec_config.application_record_class.connection.execute('SET FOREIGN_KEY_CHECKS = 0')
    end
  end
end
