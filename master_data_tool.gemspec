require_relative "lib/master_data_tool/version"

Gem::Specification.new do |spec|
  spec.name = "master_data_tool"
  spec.version = MasterDataTool::VERSION
  spec.authors = ["Takahiro Ooishi"]
  spec.email = ["taka0125@gmail.com"]

  spec.summary = "マスタデータの管理ツール"
  spec.description = "システムが稼働する上で最初から必要なデータ（マスタデータ）を管理するツールです。"
  spec.homepage = "https://github.com/taka0125/master_data_tool"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir['LICENSE', 'README.md', 'lib/**/*', 'exe/**/*', 'sig/**/*']
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'mysql2'
  spec.add_development_dependency 'psych', '~> 3.1'
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'ridgepole'
  spec.add_development_dependency 'database_cleaner-active_record'
  spec.add_development_dependency 'standalone_activerecord_boot_loader', '>= 0.3  '
  spec.add_development_dependency 'simplecov'

  spec.add_dependency 'activerecord', '>= 5.1.7'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'thor'
  spec.add_dependency 'activerecord-import'
end
