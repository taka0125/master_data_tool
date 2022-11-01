DUMMY_APP_ROOT = Pathname.new(__dir__).join('dummy')

MasterDataTool.configure do |config|
  config.master_data_dir = DUMMY_APP_ROOT.join('db/fixtures')
end

instance = StandaloneActiverecordBootLoader::Instance.new(
  DUMMY_APP_ROOT,
  env: ENV['RAILS_ENV']
)
instance.execute
