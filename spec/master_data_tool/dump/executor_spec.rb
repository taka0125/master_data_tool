# frozen_string_literal: true

RSpec.describe MasterDataTool::Dump::Executor do
  describe '#execute' do
    let(:executor) do
      described_class.new(
        spec_config: spec_config
      )
    end
    let(:spec_config) { build_spec_config('') }

    subject { executor.execute }

    before do
      MasterDataTool.configure do |config|
        config.master_data_dir = DUMMY_APP_ROOT.join('tmp/fixtures')
      end

      Item.create!(id: 123, field1: 'dump1', field2: 'dump2', field3: 'dump3')
    end

    after do
      MasterDataTool.config.master_data_dir.join('items.csv').delete
    end

    it 'DBのデータをダンプする' do
      subject

      expected_csv = <<~EOD
      "id","field1","field2","field3"
      "123","dump1","dump2","dump3"
      EOD

      expect(MasterDataTool.config.master_data_dir.join('items.csv').read).to eq expected_csv
    end
  end
end
