# frozen_string_literal: true

RSpec.describe MasterDataTool::Report::ImportReport do
  describe '#print' do
    let(:report) { MasterDataTool::Report::ImportReport.new(master_data) }
    let(:master_data) { MasterDataTool::MasterData.new(MasterDataTool.config.master_data_dir.join('tags.csv'), Tag) }
    let(:io) { StringIO.new }

    subject { report.print(DebugPrinter.new(io)) }

    before do
      MasterDataTool.configure do |config|
        config.master_data_dir = DUMMY_APP_ROOT.join('db/fixtures')
      end
    end

    context 'DBにデータが入っていない' do
      before do
        master_data.load
      end

      it 'レポートが表示される' do
        expected = <<-EOD
operation:import	label:count	table_name:tags	before:0	after:2
operation:import	label:affected	table_name:tags	affected:true
operation:import	label:new_count	table_name:tags	count:2
operation:import	label:updated_count	table_name:tags	count:0
operation:import	label:no_change_count	table_name:tags	count:0
operation:import	label:deleted_count	table_name:tags	count:0
operation:import	label:detail	table_name:tags	status:new	id:1
operation:import	label:detail	table_name:tags	status:new	id:2
        EOD

        subject

        expect(io.string).to eq expected
      end
    end

    context 'DBに入っているデータから追加があった' do
      before do
        MasterDataTool::Import::Executor.new(dry_run: false, report_printer: DebugPrinter.new(StringIO.new)).execute
      end

      it 'レポートが表示される' do
        MasterDataTool.configure do |config|
          config.master_data_dir = DUMMY_APP_ROOT.join('db/fixtures/import_report_spec/new')
        end
        master_data.load

        expected = <<-EOD
operation:import	label:count	table_name:tags	before:2	after:3
operation:import	label:affected	table_name:tags	affected:true
operation:import	label:new_count	table_name:tags	count:1
operation:import	label:updated_count	table_name:tags	count:0
operation:import	label:no_change_count	table_name:tags	count:2
operation:import	label:deleted_count	table_name:tags	count:0
operation:import	label:detail	table_name:tags	status:new	id:3
operation:import	label:detail	table_name:tags	status:no_change	id:1
operation:import	label:detail	table_name:tags	status:no_change	id:2
        EOD

        subject

        expect(io.string).to eq expected
      end
    end

    context 'DBに入っているデータから削除があった' do
      before do
        MasterDataTool::Import::Executor.new(dry_run: false, report_printer: DebugPrinter.new(StringIO.new)).execute
      end

      it 'レポートが表示される' do
        MasterDataTool.configure do |config|
          config.master_data_dir = DUMMY_APP_ROOT.join('db/fixtures/import_report_spec/delete')
        end
        master_data.load

        expected = <<-EOD
operation:import	label:count	table_name:tags	before:2	after:1
operation:import	label:affected	table_name:tags	affected:true
operation:import	label:new_count	table_name:tags	count:0
operation:import	label:updated_count	table_name:tags	count:0
operation:import	label:no_change_count	table_name:tags	count:1
operation:import	label:deleted_count	table_name:tags	count:1
operation:import	label:detail	table_name:tags	status:no_change	id:2
operation:import	label:detail	table_name:tags	status:deleted	id:1
        EOD

        subject

        expect(io.string).to eq expected
      end
    end

    context 'DBに入っているデータから更新があった' do
      before do
        MasterDataTool::Import::Executor.new(dry_run: false, report_printer: DebugPrinter.new(StringIO.new)).execute
      end

      it 'レポートが表示される' do
        MasterDataTool.configure do |config|
          config.master_data_dir = DUMMY_APP_ROOT.join('db/fixtures/import_report_spec/update')
        end
        master_data.load

        expected = <<-EOD
operation:import	label:count	table_name:tags	before:2	after:2
operation:import	label:affected	table_name:tags	affected:true
operation:import	label:new_count	table_name:tags	count:0
operation:import	label:updated_count	table_name:tags	count:1
operation:import	label:no_change_count	table_name:tags	count:1
operation:import	label:deleted_count	table_name:tags	count:0
operation:import	label:detail	table_name:tags	status:updated	id:2	detail:{"name"=>["tag2", "tag222"]}
operation:import	label:detail	table_name:tags	status:no_change	id:1
        EOD

        subject

        expect(io.string).to eq expected
      end
    end

  end
end
