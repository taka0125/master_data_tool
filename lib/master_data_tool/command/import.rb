module MasterDataTool
  module Command
    module Import
      extend ActiveSupport::Concern

      included do
        option :spec_name, default: nil, type: :string
        option :dry_run, default: true, type: :boolean
        option :verify, default: true, type: :boolean
        option :silent, default: false, type: :boolean
        option :override_identifier, default: nil, type: :string

        # import config
        option :only_import_tables, default: MasterDataTool::Import::Config::DEFAULT_VALUES[:only_tables], type: :array
        option :except_import_tables, default: MasterDataTool::Import::Config::DEFAULT_VALUES[:except_tables], type: :array
        option :skip_no_change, default: MasterDataTool::Import::Config::DEFAULT_VALUES[:skip_no_change], type: :boolean
        option :ignore_foreign_key_when_delete, default: MasterDataTool::Import::Config::DEFAULT_VALUES[:ignore_foreign_key_when_delete], type: :boolean

        # verify config
        option :only_verify_tables, default: MasterDataTool::Verify::Config::DEFAULT_VALUES[:only_tables], type: :array
        option :except_verify_tables, default: MasterDataTool::Verify::Config::DEFAULT_VALUES[:except_tables], type: :array
        option :preload_belongs_to_associations, default: MasterDataTool::Verify::Config::DEFAULT_VALUES[:preload_belongs_to_associations], type: :boolean

        desc 'import', 'import'
        def import
          spec_config = MasterDataTool.config.spec_config(options[:spec_name])
          raise "正しいspec_nameを指定して下さい" unless spec_config

          build_import_executor(spec_config).execute
        end

        option :dry_run, default: true, type: :boolean
        option :verify, default: true, type: :boolean
        option :silent, default: false, type: :boolean
        option :override_identifier, default: nil, type: :string

        # import config
        option :only_import_tables, default: MasterDataTool::Import::Config::DEFAULT_VALUES[:only_tables], type: :array
        option :except_import_tables, default: MasterDataTool::Import::Config::DEFAULT_VALUES[:except_tables], type: :array
        option :skip_no_change, default: MasterDataTool::Import::Config::DEFAULT_VALUES[:skip_no_change], type: :boolean
        option :ignore_foreign_key_when_delete, default: MasterDataTool::Import::Config::DEFAULT_VALUES[:ignore_foreign_key_when_delete], type: :boolean

        # verify config
        option :only_verify_tables, default: MasterDataTool::Verify::Config::DEFAULT_VALUES[:only_tables], type: :array
        option :except_verify_tables, default: MasterDataTool::Verify::Config::DEFAULT_VALUES[:except_tables], type: :array
        option :preload_belongs_to_associations, default: MasterDataTool::Verify::Config::DEFAULT_VALUES[:preload_belongs_to_associations], type: :boolean

        desc 'import_all', 'import all'
        def import_all
          MasterDataTool.config.spec_configs.each do |spec_config|
            build_import_executor(spec_config).execute
          end
        end

        private

        def build_import_executor(spec_config)
          import_config = spec_config.import_config || MasterDataTool::Import::Config.new(
            only_tables: options[:only_import_tables],
            except_tables: options[:except_import_tables],
            skip_no_change: options[:skip_no_change],
            ignore_foreign_key_when_delete: options[:ignore_foreign_key_when_delete]
          )

          verify_config = spec_config.verify_config || MasterDataTool::Verify::Config.new(
            only_tables: options[:only_verify_tables],
            except_tables: options[:except_verify_tables],
            preload_belongs_to_associations: options[:preload_belongs_to_associations],
            preload_associations: {},
            eager_load_associations: {}
          )

          MasterDataTool::Import::Executor.new(
            spec_config: spec_config,
            import_config: import_config,
            verify_config: verify_config,
            dry_run: options[:dry_run],
            verify: options[:verify],
            silent: options[:silent],
            override_identifier: options[:override_identifier]
          )
        end
      end
    end
  end
end
