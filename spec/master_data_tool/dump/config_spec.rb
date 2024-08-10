# frozen_string_literal: true

RSpec.describe MasterDataTool::Dump::Config do
  describe '#configure' do
    it '設定を変更できる' do
      config = described_class.default_config
      config.configure do |c|
        c.ignore_empty_table = false
      end

      expect(config.ignore_empty_table).to eq false
    end
  end
end
