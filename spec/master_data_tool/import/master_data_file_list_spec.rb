# frozen_string_literal: true

RSpec.describe MasterDataTool::Import::MasterDataFileList do
  before do
    MasterDataTool.configure do |config|
      config.master_data_dir = DUMMY_APP_ROOT.join('db/fixtures/override_spec')
    end
  end

  describe '#build' do
    subject { described_class.new(override_identifier: override_identifier).build }

    context 'override_identifier = nil' do
      let(:override_identifier) {}

      it do
        expected_results = [
          MasterDataTool::MasterDataFile.new(
            'items',
            Pathname.new(MasterDataTool.config.master_data_dir).join('items.csv'),
            nil
          ),
          MasterDataTool::MasterDataFile.new(
            'tags',
            Pathname.new(MasterDataTool.config.master_data_dir).join('tags.csv'),
            nil
          ),
        ].sort_by(&:basename)

        expect(subject.sort_by(&:basename)).to eq expected_results
      end
    end

    context 'override_identifierを指定した' do
      let(:override_identifier) { 'sample' }

      it do
        expected_results = [
          MasterDataTool::MasterDataFile.new(
            'items',
            Pathname.new(MasterDataTool.config.master_data_dir).join('items.csv'),
            nil
          ),
          MasterDataTool::MasterDataFile.new(
            'tags',
            Pathname.new(MasterDataTool.config.master_data_dir).join(override_identifier).join('tags.csv'),
            override_identifier
          ),
        ].sort_by(&:basename)

        expect(subject.sort_by(&:basename)).to eq expected_results
      end
    end
  end
end
