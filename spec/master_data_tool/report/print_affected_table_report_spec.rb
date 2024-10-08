# frozen_string_literal: true

RSpec.describe MasterDataTool::Report::PrintAffectedTableReport do
  describe '#print' do
    let(:master_data) { build_master_data('', MasterDataTool.config.master_data_dir.join('items.csv'), nil) }
    let(:io) { StringIO.new }
    let(:spec_config) { build_spec_config('') }

    subject { master_data.print_affected_table&.print(printer: DebugPrinter.new(io)) }

    before do
      MasterDataTool.configure do |config|
        config.master_data_dir = DUMMY_APP_ROOT.join('db/fixtures')
      end
    end

    context 'データ投入が行われる' do
      it 'レポートが表示される' do
        expected = <<-EOD
operation:affected_table	table_name:items
        EOD

        master_data.load

        subject

        expect(io.string).to eq expected
      end
    end

    context 'データ投入は行われない' do
      it 'レポートは表示されない' do
        import_config = MasterDataTool::Import::Config.default_config
        verify_config = MasterDataTool::Verify::Config.default_config
        MasterDataTool::Import::Executor.new(spec_config: spec_config, import_config: import_config, verify_config: verify_config, dry_run: false, verify: false, report_printer: DebugPrinter.new(StringIO.new)).execute
        master_data.load

        expect(subject).to be_nil
      end
    end
  end
end

