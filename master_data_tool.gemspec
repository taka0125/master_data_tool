# frozen_string_literal: true

require_relative "lib/master_data_tool/version"

Gem::Specification.new do |spec|
  spec.name = "master_data_tool"
  spec.version = MasterDataTool::VERSION
  spec.authors = ["Takahiro Ooishi"]
  spec.email = ["taka0125@gmail.com"]

  spec.summary = "マスタデータの管理ツール"
  spec.description = "システムが稼働する上で最初から必要なデータ（マスタデータ）を管理するツールです。"
  spec.homepage = "https://github.com/taka0125/master_data_tool"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rails', '5.2.6.2'
  spec.add_development_dependency 'mysql2'
  spec.add_development_dependency 'psych', '~> 3.1'

  spec.add_dependency 'rails', '>= 5.1.7'
  spec.add_dependency 'thor'
  spec.add_dependency 'activerecord-import'
end
