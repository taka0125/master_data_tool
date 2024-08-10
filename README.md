# MasterDataTool

[![Build Status](https://github.com/taka0125/master_data_tool/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/taka0125/master_data_tool/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/master_data_tool.svg)](https://badge.fury.io/rb/master_data_tool)
[![Maintainability](https://api.codeclimate.com/v1/badges/5fc8420c4fe83a2e6c92/maintainability)](https://codeclimate.com/github/taka0125/master_data_tool/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5fc8420c4fe83a2e6c92/test_coverage)](https://codeclimate.com/github/taka0125/master_data_tool/test_coverage)

システムが稼働する上で最初から必要なデータ（マスタデータ）を管理するツール

以下の機能を提供する

- CSVからテーブルにデータを入れる
    - dry-runができる
    - 新規・更新・変更なし・削除がわかる
    - CSVのハッシュ値をDBに記録し差分があったテーブルのみ取り込みを実行する
- 既存DBからCSVとしてデータをダンプする

## 前提条件

- マスタデータの更新は同時並行で実行されない
- `db/fixtures/#{spec_name}/#{table_name}.csv` の命名規則
    - 1DBの場合は `db/fixtures/#{table_name}.csv`

## インストール

```ruby
gem 'master_data_tool'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install master_data_tool

## 初期設定

`config/initializers/master_data_tool.rb`

### 複数DB

```ruby
Rails.application.reloader.to_prepare do
  MasterDataTool.configure do |config|
    primary_config = MasterDataTool::SpecConfig.new(
      spec_name: :primary,
      master_data_dir: Rails.root.join('db/fixtures/primary'),
      application_record_class: ::ApplicationRecord
    )

    animals_config = MasterDataTool::SpecConfig.new(
      spec_name: :animals,
      master_data_dir: Rails.root.join('db/fixtures/animals'),
      application_record_class: ::AnimalsRecord
    )

    config.spec_configs = [
      primary_config, animals_config
    ]
  end

end
```

### 単一DB

```ruby
Rails.application.reloader.to_prepare do
  MasterDataTool.configure do |config|
    primary_config = MasterDataTool::SpecConfig.new(
      spec_name: '',
      master_data_dir: Rails.root.join('db/fixtures'),
      application_record_class: ::ApplicationRecord
    )

    config.spec_configs = [
      primary_config
    ]
  end
end
```

## Usage

### マスタデータの投入

| option                          | default | 内容                                                              |
|---------------------------------|---------|-----------------------------------------------------------------|
| --dry-run                       | true    | dry-runモードで実行する（データ変更は行わない）                                     |
| --verify                        | true    | データ投入後に全テーブル・全レコードのバリデーションチェックを行う                               |
| --spec-name                     | nil     | 対象となるDBのspec name                                               |
| --only-import-tables            | []      | 指定したテーブルのみデータ投入を行う                                              |
| --except-import-tables          | []      | 指定したテーブルのデータ投入を行わない                                             |
| --only-verify-tables            | []      | 指定したテーブルのみ投入後のバリデーションチェックを行う                                    |
| --except-verify-tables          | []      | 指定したテーブルのバリデーションチェックを行わない                                       |
| --skip-no-change                | true    | CSVファイルに更新がないテーブルをスキップする                                        |
| --silent                        | false   | 結果の出力をやめる                                                       |
| --delete-all-ignore-foreign-key | false   | 外部キー制約を無視してレコードを消すかどうか                                          |
| --override-identifier           | nil     | fixtures/#{override_identifier} のディレクトリにある内容でfixturesを上書きして投入する |

```bash
bundle exec master_data_tool import
```

は以下のオプションを指定したものと一緒

```bash
bundle exec thor master_data_tool import \
  --dry-run=true \
  --verify=true \
  --only-import-tables="" \
  --except-import-tables="" \
  --only-verify-tables="" \
  --except-verify-tables="" \
  --skip-no-change=true \
  --silent=false \
  --delete-all-ignore-foreign-key=false
```

### ダンプ

| option                | default | 内容              |
|-----------------------|---------|-----------------|
| --ignore-empty-table  | true    | 空のテーブルを無視する     |
| --ignore-tables       | []      | 指定したテーブルを無視する   |
| --ignore-column-names | []      | 指定したカラムを無視する    |
| --only-tables | nil     | 指定したテーブルのみダンプする |
| --verbose      | false   | 詳細表示            |

```bash
bundle exec master_data_tool dump
```

は以下のオプションを指定したものと一緒

```bash
bundle exec master_data_tool dump \
  --ignore-empty-table=true \
  --ignore-tables="" \
  --ignore-column-names="" \
  --only-tables="" \
  --verbose=false
```

## マイグレーション

`master_data_statuses` というテーブルにCSVファイルのハッシュ値を記録し差分更新に利用する

```
bundle exec rails generate master_data_tool:install
```

を実行するとマイグレーションファイルが生成される。

ridgepoleの場合は以下のような定義で実行する

```
create_table 'master_data_statuses', id: :bigint, unsigned: true, force: :cascade, comment: "マスタデータの状態管理用テーブル" do |t|
  t.string   "name", limit: 255, null: false, comment: 'テーブル名'
  t.string   "version", limit: 255, null: false, comment: 'ハッシュ値'
  t.datetime "created_at", null: false, comment: '作成日時'
  t.datetime "updated_at", null: false, comment: '更新日時'
end

add_index 'master_data_statuses', ["name"], name: "idx_master_data_statuses_1", unique: true, using: :btree
add_index 'master_data_statuses', ["name", "version"], name: "idx_master_data_statuses_2", using: :btree
```

## Tips

### マスタデータ投入でどうなるか？を調べる

```
RAILS_ENV=development bundle exec master_data_tool import > /tmp/dry-run.txt
```

- 影響を受けるテーブル

```
grep 'operation:affected_table' /tmp/dry-run.txt
```

- 更新されるレコード

```
grep 'operation:import' /tmp/dry-run.txt | grep 'label:detail' | grep 'status:updated'
```

- 削除されるレコード

```
grep 'operation:import' /tmp/dry-run.txt | grep 'label:detail' | grep 'status:deleted'
```

- 追加されるレコード

```
grep 'operation:import' /tmp/dry-run.txt | grep 'label:detail' | grep 'status:new'
```

## TODO

- upsert_allに移行する

## Test

docker-composeでMySQLを立ち上げてテストを実行する。

```
docker-compose up -d
```

以下のENVを設定すること。

```
export DB_HOST=127.0.0.1
export DB_PORT=`docker port master_data_tool_mysql57 3306 | cut -f 2 -d ':'`
export DB_USERNAME=root
export DB_PASSWORD=f3WpxNreVT2NgQry
export DB_NAME=master_data_tool_test
```

- dockerでMySQLを立ち上げるたびにポートは変わるのでDB_PORTは都度設定する
    - direnvを使っているならば `direnv reload` すればいい

```
./scripts/setup.sh
```

## rspec

```
bundle exec appraisal activerecord52 rspec
bundle exec appraisal activerecord61 rspec
bundle exec appraisal activerecord70 rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/taka0125/master_data_tool.
