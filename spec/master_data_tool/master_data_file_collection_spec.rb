# frozen_string_literal: true

RSpec.describe MasterDataTool::MasterDataFileCollection do
  before do
    MasterDataTool.configure do |config|
      config.master_data_dir = DUMMY_APP_ROOT.join('db/fixtures/override_spec')
    end
  end

  describe '#initialize' do
    subject { described_class.new(spec_name: spec_name, override_identifier: override_identifier) }

    let(:spec_name) { '' }

    context 'override_identifier = nil' do
      let(:override_identifier) {}

      it do
        expected_results = [
          MasterDataTool::MasterDataFile.new(
            spec_name: '',
            table_name: 'items',
            path: MasterDataTool.config.master_data_dir.join('items.csv'),
            override_identifier: nil
          ),
          MasterDataTool::MasterDataFile.new(
            spec_name: '',
            table_name: 'tags',
            path: MasterDataTool.config.master_data_dir.join('tags.csv'),
            override_identifier: nil
          ),
        ].sort_by(&:basename)

        expect(subject.each.to_a.sort_by(&:basename)).to eq expected_results
      end
    end

    context 'override_identifierを指定した' do
      let(:override_identifier) { 'sample' }

      it do
        expected_results = [
          MasterDataTool::MasterDataFile.new(
            spec_name: '',
            table_name: 'items',
            path: Pathname.new(MasterDataTool.config.master_data_dir).join('items.csv'),
            override_identifier: nil
          ),
          MasterDataTool::MasterDataFile.new(
            spec_name: '',
            table_name: 'tags',
            path: Pathname.new(MasterDataTool.config.master_data_dir).join(override_identifier).join('tags.csv'),
            override_identifier: override_identifier
          ),
        ].sort_by(&:basename)

        expect(subject.each.to_a.sort_by(&:basename)).to eq expected_results
      end
    end
  end
end
