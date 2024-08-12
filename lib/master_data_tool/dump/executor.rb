# frozen_string_literal: true

module MasterDataTool
  module Dump
    class Executor
      Error = Struct.new(:table, :exception)

      def initialize(spec_config:, dump_config:, verbose: false)
        @spec_config = spec_config
        @dump_config = dump_config
        @verbose = verbose
      end

      def execute
        [].tap do |errors|
          spec_config.application_record_class.connection.tables.each do |table|
            if dump_config.ignore_tables.include?(table)
              print_message "[ignore] #{table}"

              next
            end

            if dump_config.only_tables.any? && !dump_config.only_tables.include?(table)
              print_message "[skip] #{table}"
              next
            end

            dump_to_csv(table)
          rescue StandardError => e
            errors << Error.new(table, e)
          end
        end
      end

      private

      attr_reader :spec_config, :dump_config, :verbose

      def print_message(message)
        return unless verbose

        puts message
      end

      def dump_to_csv(table)
        model_klass = Object.const_get(table.classify)
        if ignore?(model_klass)
          print_message "[ignore] #{table}"

          return
        end

        csv_path = MasterDataTool.config.csv_dir_for(spec_name: spec_config.spec_name).join("#{table}.csv")
        FileUtils.mkdir_p(csv_path.dirname)

        CSV.open(csv_path, 'w', force_quotes: true) do |csv|
          headers = model_klass.column_names - dump_config.ignore_column_names

          csv << headers

          model_klass.all.find_each do |record|
            items = []
            headers.each do |name|
              items << record[name]
            end

            csv << items
          end
        end
      end

      def ignore?(model_klass)
        return false unless dump_config.ignore_empty_table

        model_klass.count < 1
      end
    end
  end
end
