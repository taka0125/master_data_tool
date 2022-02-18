# frozen_string_literal: true

require 'active_record'
require 'active_support/time'

DUMMY_APP_ROOT = Pathname.new(__dir__).join('dummy-common')
config_database_yml_file = DUMMY_APP_ROOT.join('config/database.yml')
DATABASE_CONFIG = YAML::load(ERB.new(File.read(config_database_yml_file)).result)

def create_database_if_not_exists(env: 'test')
  conn_spec = DATABASE_CONFIG[env]
  database = conn_spec['database']

  ActiveRecord::Base.establish_connection(conn_spec.merge(database: nil))
  ActiveRecord::Base.connection.execute("CREATE DATABASE IF NOT EXISTS #{database}")
end
