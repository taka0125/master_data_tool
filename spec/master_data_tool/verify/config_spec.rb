# frozen_string_literal: true

RSpec.describe MasterDataTool::Verify::Config do
  describe '#configure' do
    it '設定を変更できる' do
      config = described_class.default_config
      config.configure do |c|
        c.only_tables = ['table1']
      end

      expect(config.only_tables).to eq ['table1']
    end
  end
end
