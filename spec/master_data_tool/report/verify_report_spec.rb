# frozen_string_literal: true

RSpec.describe MasterDataTool::Report::VerifyReport do
  describe '#print' do
    let(:master_data) { MasterDataTool::MasterData.new(spec_config: spec_config, master_data_file: MasterDataTool.config.master_data_dir.join('items.csv'), model_klass: Item) }
    let(:io) { StringIO.new }
    let(:spec_config) { build_spec_config('') }
    let(:verify_config) { MasterDataTool::Verify::Config.default_config }

    subject { master_data.verify!(verify_config: verify_config, ignore_fail: true).print(printer: DebugPrinter.new(io)) }

    before do
      MasterDataTool.configure do |config|
        config.master_data_dir = DUMMY_APP_ROOT.join('db/fixtures')
      end
    end

    context '正しいデータのみ' do
      before do
        import_config = MasterDataTool::Import::Config.default_config
        verify_config = MasterDataTool::Verify::Config.default_config
        MasterDataTool::Import::Executor.new(spec_config: spec_config, import_config: import_config, verify_config: verify_config, dry_run: false, verify: false, report_printer: DebugPrinter.new(StringIO.new)).execute
      end

      it 'レポートが表示される' do
        expected = <<-EOD
operation:verify	table_name:items	valid:true	id:1
operation:verify	table_name:items	valid:true	id:2
operation:verify	table_name:items	valid:true	id:3
        EOD

        subject

        expect(io.string).to eq expected
      end
    end

    context '不正なデータを含む' do
      before do
        MasterDataTool.configure do |config|
          config.master_data_dir = DUMMY_APP_ROOT.join('db/fixtures/verify_spec')
        end

        import_config = MasterDataTool::Import::Config.default_config
        verify_config = MasterDataTool::Verify::Config.default_config
        MasterDataTool::Import::Executor.new(spec_config: spec_config, import_config: import_config, verify_config: verify_config, dry_run: false, verify: false, report_printer: DebugPrinter.new(StringIO.new)).execute
      end

      it 'レポートが表示される' do
        expected = <<-EOD
operation:verify	table_name:items	valid:true	id:1
operation:verify	table_name:items	valid:true	id:2
operation:verify	table_name:items	valid:false	id:3
        EOD

        subject

        expect(io.string).to eq expected
      end
    end
  end
end
