# frozen_string_literal: true

require 'active_record'
require 'activerecord-import'
require 'openssl'

module MasterDataTool
  class MasterDataStatus < ::ActiveRecord::Base
    self.table_name = 'master_data_statuses'

    validates :name,
              presence: true

    validates :version,
              presence: true

    class << self
      def build(master_data_file)
        version = decide_version(master_data_file.path)
        new(name: MasterDataTool.resolve_table_name(master_data_file.path, master_data_file.override_identifier), version: version)
      end

      def import_records!(records, dry_run: true)
        if dry_run
          pp records
        else
          import!(records, validate: true, on_duplicate_key_update: %w[name version], timestamps: true)
        end
      end

      # @param [MasterDataTool::MasterDataFile] master_data_file
      def master_data_will_change?(master_data_file)
        new_version = decide_version(master_data_file.path)
        !where(name: master_data_file.table_name, version: new_version).exists?
      end

      def decide_version(csv_path)
        OpenSSL::Digest::SHA256.hexdigest(File.open(csv_path).read)
      end
    end
  end
end
