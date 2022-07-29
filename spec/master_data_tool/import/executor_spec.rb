# frozen_string_literal: true

RSpec.describe MasterDataTool::Import::Executor do
  describe '#execute' do
    let(:executor) do
      described_class.new(
        dry_run: false,
        verify: verify,
        only_import_tables: only_import_tables,
        except_import_tables: except_import_tables,
        only_verify_tables: only_verify_tables,
        except_verify_tables: except_verify_tables,
        skip_no_change: skip_no_change,
        silent: true,
        delete_all_ignore_foreign_key: delete_all_ignore_foreign_key,
        override_identifier: override_identifier,
        report_printer: DebugPrinter.new(StringIO.new)
      )
    end

    subject { executor.execute }

    let(:verify) { true }
    let(:only_import_tables) { [] }
    let(:except_import_tables) { [] }
    let(:only_verify_tables) { [] }
    let(:except_verify_tables) { [] }
    let(:skip_no_change) { true }
    let(:delete_all_ignore_foreign_key) { false }
    let(:override_identifier) {}

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

    context 'except_import_tablesオプション' do
      context 'デフォルト値' do
        let(:except_import_tables) { [] }

        it 'すべてのテーブルにデータが投入される' do
          subject

          expect(Item.count).to eq 3
          expect(Tag.count).to eq 2
        end
      end

      context '指定のテーブルを除外' do
        let(:except_import_tables) { %w[tags] }

        it '指定のテーブルのみデータが投入される' do
          subject

          expect(Item.count).to eq 3
          expect(Tag.count).to eq 0
        end
      end

      context 'only_import_tables と except_import_tables を指定した時' do
        let(:except_import_tables) { %w[tags] }
        let(:only_import_tables) { %w[tags] }

        it 'except_import_tablesが優先される' do
          result = subject

          result.each do |master_data|
            expect(master_data).not_to be_loaded
          end

          expect(Item.count).to eq 0
          expect(Tag.count).to eq 0
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

    context 'except_verify_tablesオプション' do
      let(:master_data_dir) { 'db/fixtures/only_verify_tables_spec' }

      context 'デフォルト値' do
        let(:except_verify_tables) { [] }

        it 'すべてのテーブルでバリデーションが走る' do
          expect { subject }.to raise_error(MasterDataTool::VerifyFailed, '[items] id = 3 is invalid')
        end
      end

      context '指定のテーブルのみ' do
        let(:except_verify_tables) { %w[items] }

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

        it '投入済みのテーブルはロードされない' do
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

    context 'delete_all_ignore_foreign_keyオプション' do
      let(:delete_all_ignore_foreign_key) { true }
      let(:master_data_dir) { 'db/fixtures/foreign_key_spec' }
      let(:skip_no_change) { false }
      let(:silent) { false }

      context 'delete_all_ignore_foreign_key = true' do
        it 'データが投入できる' do
          MasterDataTool.configure do |config|
            config.master_data_dir = DUMMY_APP_ROOT.join(master_data_dir)
          end

          MasterDataTool::Import::Executor.new(dry_run: false, report_printer: DebugPrinter.new(StringIO.new)).execute

          # 擬似的にマスタデータの変更を行う
          MasterDataTool.configure do |config|
            config.master_data_dir = DUMMY_APP_ROOT.join(master_data_dir + '/after')
          end

          # 通常ではtaggingsの前にtagsの削除が起こるが外部キー制約によりエラーになる
          subject

          expect(Item.count).to eq 3
          expect(Tag.count).to eq 3
          expect(Tagging.count).to eq 4
        end
      end
    end

    context 'override_identifierオプション' do
      let(:master_data_dir) { 'db/fixtures/override_spec' }
      let(:override_identifier) { 'sample' }

      it 'tagsだけsampleディレクトリのデータが使われる' do
        subject

        expect(Item.count).to eq 3
        expect(Tag.count).to eq 4
      end
    end

    # FIXME: 本当はpreloadされている事を確認したい
    context 'preloadオプション（configureでのみ設定可）' do
      let(:master_data_dir) { 'db/fixtures/preload_spec' }

      before do
        ActiveRecord::Base.logger = Logger.new(STDOUT)

        MasterDataTool.configure do |config|
          config.master_data_dir = DUMMY_APP_ROOT.join(master_data_dir)
          config.preload_associations = {
            ItemTagging: [:item, :tag],
          }
        end
      end

      after do
        ActiveRecord::Base.logger = nil
      end

      it 'エラーにはならない' do
        expect { subject }.not_to raise_error
      end
    end

    # FIXME: 本当はpreloadされている事を確認したい
    context 'eager_loadオプション（configureでのみ設定可）' do
      let(:master_data_dir) { 'db/fixtures/eager_load_spec' }

      before do
        ActiveRecord::Base.logger = Logger.new(STDOUT)

        MasterDataTool.configure do |config|
          config.master_data_dir = DUMMY_APP_ROOT.join(master_data_dir)
          config.eager_load_associations = {
            ItemTagging: [:item, :tag],
          }
        end
      end

      after do
        ActiveRecord::Base.logger = nil
      end

      it 'エラーにはならない' do
        expect { subject }.not_to raise_error
      end
    end
  end
end
