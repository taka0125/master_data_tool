RSpec.describe MasterDataTool do
  describe '#need_skip_table?' do
    subject { described_class.need_skip_table?(table_name, only, except) }

    let(:table_name) { 'table_name' }

    context 'onlyのみを指定' do
      context 'table_nameに一致する' do
        let(:only) { ['table_name'] }
        let(:except) { nil }

        it { is_expected.to eq false }
      end

      context 'table_nameに一致しない' do
        let(:only) { ['table_name2'] }
        let(:except) { nil }

        it { is_expected.to eq true }
      end
    end

    context 'exceptのみを指定' do
      context 'table_nameに一致する' do
        let(:only) { nil }
        let(:except) { ['table_name'] }

        it { is_expected.to eq true }
      end

      context 'table_nameに一致しない' do
        let(:only) { nil }
        let(:except) { ['table_name2'] }

        it { is_expected.to eq false }
      end
    end

    context 'onlyとexceptを指定' do
      context 'onlyとexceptの両方に一致する' do
        let(:only) { ['table_name'] }
        let(:except) { ['table_name'] }

        it { is_expected.to eq true }
      end
    end
  end
end
