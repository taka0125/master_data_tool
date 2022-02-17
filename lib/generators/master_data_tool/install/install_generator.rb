require "rails/generators"
require "rails/generators/active_record"

module MasterDataTool
  class InstallGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration

    source_root File.expand_path("templates", __dir__)

    def self.next_migration_number(dirname)
      ::ActiveRecord::Generators::Base.next_migration_number(dirname)
    end

    def create_migration_file
      migration_dir = File.expand_path("db/migrate")
      template = 'create_master_data_statuses'

      if self.class.migration_exists?(migration_dir, template)
        ::Kernel.warn "Migration already exists: #{template}"
      else
        migration_template(
          "#{template}.rb.erb",
          "db/migrate/#{template}.rb",
          migration_version: migration_version
        )
      end
    end

    private

    def migration_version
      format(
        "[%d.%d]",
        ActiveRecord::VERSION::MAJOR,
        ActiveRecord::VERSION::MINOR
      )
    end
  end
end
