# frozen_string_literal: true

RSpec.describe MasterDataTool::Import::Executor do
  describe '#execute' do
    let(:executor) do
      described_class.new(
        dry_run: false,
        verify: verify,
        only_import_tables: only_import_tables,
        only_verify_tables: only_verify_tables,
        skip_no_change: skip_no_change,
        silent: true,
        report_printer: DebugPrinter.new(StringIO.new)
      )
    end

    subject { executor.execute }

    let(:verify) { true }
    let(:only_import_tables) { [] }
    let(:only_verify_tables) { [] }
    let(:skip_no_change) { true }

    let(:master_data_dir) { 'db/fixtures' }

    before do
      MasterDataTool.configure do |config|
        config.master_data_dir = DUMMY_APP_ROOT.join(master_data_dir)
      end
    end

    context 'verifyオプション' do
      let(:master_data_dir) { 'db/fixtures/verify_spec' }

      context 'verify = true' do
        let(:verify) { true }

        it { expect { subject }.to raise_error(MasterDataTool::VerifyFailed, '[items] id = 3 is invalid') }
      end

      context 'verify = false' do
        let(:verify) { false }

        it 'エラーにはならない' do
          expect { subject }.not_to raise_error
        end
      end
    end

    context 'only_import_tablesオプション' do
      let(:master_data_dir) { 'db/fixtures/only_import_tables_spec' }

      context 'デフォルト値' do
        let(:only_import_tables) { [] }

        it 'すべてのテーブルにデータが投入される' do
          subject

          expect(Item.count).to eq 3
          expect(Tag.count).to eq 2
        end
      end

      context '指定のテーブルのみ' do
        let(:only_import_tables) { %w[tags] }

        it '指定のテーブルのみデータが投入される' do
          subject

          expect(Item.count).to eq 0
          expect(Tag.count).to eq 2
        end
      end
    end

    context 'only_verify_tablesオプション' do
      let(:master_data_dir) { 'db/fixtures/only_verify_tables_spec' }

      context 'デフォルト値' do
        let(:only_verify_tables) { [] }

        it 'すべてのテーブルでバリデーションが走る' do
          expect { subject }.to raise_error(MasterDataTool::VerifyFailed, '[items] id = 3 is invalid')
        end
      end

      context '指定のテーブルのみ' do
        let(:only_verify_tables) { %w[tags] }

        # エラーとなるべきitemsはスキップされるから
        it 'エラーにはならない' do
          expect { subject }.not_to raise_error
        end
      end
    end

    context 'skip_no_changeオプション' do
      let(:master_data_dir) { 'db/fixtures/skip_no_change_spec' }

      context 'skip_no_change = true' do
        let(:skip_no_change) { true }

        it '投入済みのテーブルはスキップされる' do
          result1 = executor.execute
          result1.each do |master_data|
            expect(master_data).to be_loaded
            expect(master_data).to be_affected
          end

          result2 = executor.execute
          result2.each do |master_data|
            expect(master_data).not_to be_loaded
          end
        end
      end

      context 'skip_no_change = false' do
        let(:skip_no_change) { false }

        it 'すべて再投入される' do
          result1 = executor.execute
          result1.each do |master_data|
            expect(master_data).to be_loaded
            expect(master_data).to be_affected
          end

          result2 = executor.execute
          result2.each do |master_data|
            expect(master_data).to be_loaded
          end
        end
      end
    end
  end
end
