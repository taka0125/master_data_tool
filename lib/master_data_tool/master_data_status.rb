# frozen_string_literal: true

require 'active_record'
require 'openssl'

module MasterDataTool
  class MasterDataStatus < ::ActiveRecord::Base
    self.table_name = 'master_data_statuses'

    validates :name,
              presence: true

    validates :version,
              presence: true

    def will_change?(master_data_file)
      raise unless name == master_data_file.table_name

      version != self.class.decide_version(master_data_file.path)
    end

    class << self
      def fetch_all
        all.index_by(&:name)
      end

      def build(spec_name, master_data_file)
        version = decide_version(master_data_file.path)
        new(spec_name: spec_name, name: MasterDataTool.resolve_table_name(spec_name, master_data_file.path, master_data_file.override_identifier), version: version)
      end

      def import_records!(records, dry_run: true)
        if dry_run
          pp records
          return
        end

        import_records = records.map { |obj| obj.attributes.slice(*import_columns) }
        upsert_all(import_records, update_only: %w[version])
      end

      def decide_version(csv_path)
        OpenSSL::Digest::SHA256.hexdigest(File.open(csv_path).read)
      end

      private

      def import_columns
        %w[spec_name name version]
      end
    end
  end
end
