# frozen_string_literal: true

RSpec.describe MasterDataTool::MasterDataCollection do
  before do
    MasterDataTool.configure do |config|
      config.master_data_dir = DUMMY_APP_ROOT.join('db/fixtures/collection_spec')
    end
  end

  describe '#append' do
    subject { collection.append(master_data) }

    let(:collection) { described_class.new }
    let(:master_data) { build_master_data(MasterDataTool.config.master_data_dir.join('001_tags.csv'), nil) }

    it '追加される' do
      subject
      raw_collection = collection.to_a
      expect(raw_collection).to eq [master_data]
    end
  end

  describe '#each' do
    let(:collection) { described_class.new }

    it 'ソートされたMasterDataがとれる' do
      items_master_data = build_master_data(MasterDataTool.config.master_data_dir.join('items.csv'), nil)
      tags_master_data = build_master_data(MasterDataTool.config.master_data_dir.join('001_tags.csv'), nil)

      collection.append(items_master_data)
      collection.append(tags_master_data)

      raw_collection = collection.to_a
      expect(raw_collection).to eq [tags_master_data, items_master_data]
    end
  end
end
