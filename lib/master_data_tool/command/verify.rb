module MasterDataTool
  module Command
    module Verify
      extend ActiveSupport::Concern

      included do
        desc 'verify', 'verify'

        option :spec_name, default: nil, type: :string
        option :verify, default: true, type: :boolean
        option :silent, default: false, type: :boolean
        option :override_identifier, default: nil, type: :string

        # verify config
        option :only_tables, default: MasterDataTool::Verify::Config::DEFAULT_VALUES[:only_tables], type: :array
        option :except_tables, default: MasterDataTool::Verify::Config::DEFAULT_VALUES[:except_tables], type: :array
        option :preload_belongs_to_associations, default: MasterDataTool::Verify::Config::DEFAULT_VALUES[:preload_belongs_to_associations], type: :boolean

        def verify
          spec_config = MasterDataTool.config.spec_config(options[:spec_name])
          raise "正しいspec_nameを指定して下さい" unless spec_config

          build_verify_executor(spec_config).execute
        end

        desc 'verify_all', 'verify all'

        option :verify, default: true, type: :boolean
        option :silent, default: false, type: :boolean
        option :override_identifier, default: nil, type: :string

        # verify config
        option :only_tables, default: MasterDataTool::Verify::Config::DEFAULT_VALUES[:only_tables], type: :array
        option :except_tables, default: MasterDataTool::Verify::Config::DEFAULT_VALUES[:except_tables], type: :array
        option :preload_belongs_to_associations, default: MasterDataTool::Verify::Config::DEFAULT_VALUES[:preload_belongs_to_associations], type: :boolean

        def verify_all
          MasterDataTool.config.spec_configs.each do |spec_config|
            build_verify_executor(spec_config).execute
          end
        end

        private

        def build_verify_executor(spec_config)
          verify_config = spec_config.verify_config || MasterDataTool::Verify::Config.new(
            only_tables: options[:only_tables],
            except_tables: options[:except_tables],
            preload_belongs_to_associations: options[:preload_belongs_to_associations],
            preload_associations: {},
            eager_load_associations: {}
          )

          MasterDataTool::Verify::Executor.new(
            spec_config: spec_config,
            verify_config: verify_config,
            silent: options[:silent],
            override_identifier: options[:override_identifier]
          )
        end
      end
    end
  end
end
