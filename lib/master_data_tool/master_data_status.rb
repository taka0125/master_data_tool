# frozen_string_literal: true

require 'active_record'
require 'activerecord-import'

module MasterDataTool
  class MasterDataStatus < ::ActiveRecord::Base
    self.table_name = 'master_data_statuses'

    validates :name,
              presence: true

    validates :version,
              presence: true

    class << self
      def build(csv_path)
        version = decide_version(csv_path)
        new(name: MasterDataTool.resolve_table_name(csv_path), version: version)
      end

      def import_records!(records, dry_run: true)
        if dry_run
          pp records
        else
          import!(records, validate: true, on_duplicate_key_update: %w[name version], timestamps: true)
        end
      end

      def master_data_will_change?(csv_path)
        new_version = decide_version(csv_path)
        !where(name: MasterDataTool.resolve_table_name(csv_path), version: new_version).exists?
      end

      def decide_version(csv_path)
        OpenSSL::Digest::SHA256.hexdigest(File.open(csv_path).read)
      end
    end
  end
end
