# frozen_string_literal: true

RSpec.describe MasterDataTool::Report::PrintAffectedTableReport do
  describe '#print' do
    let(:master_data_file) { MasterDataTool::MasterDataFile.new('items', MasterDataTool.config.master_data_dir.join('items.csv'), nil) }
    let(:master_data) { MasterDataTool::MasterData.new(master_data_file, Item) }
    let(:io) { StringIO.new }

    subject { master_data.print_affected_table&.print(DebugPrinter.new(io)) }

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
        MasterDataTool::Import::Executor.new(dry_run: false, verify: false, report_printer: DebugPrinter.new(StringIO.new)).execute
        master_data.load

        expect(subject).to be_nil
      end
    end
  end
end

