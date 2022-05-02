# MasterDataTool

[![Build Status](https://github.com/taka0125/master_data_tool/workflows/Ruby/badge.svg?branch=main)](https://github.com/taka0125/master_data_tool/actions)

システムが稼働する上で最初から必要なデータ（マスタデータ）を管理するツール

以下の機能を提供する

- CSVからテーブルにデータを入れる
    - dry-runができる
    - 新規・更新・変更なし・削除がわかる
    - CSVのハッシュ値をDBに記録し差分があったテーブルのみ取り込みを実行する
- 既存DBからCSVとしてデータをダンプする

## 前提条件

- マスタデータの更新は同時並行で実行されない
- `db/fixtures/#{table_name}.csv` の命名規則

## インストール

```ruby
gem 'master_data_tool'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install master_data_tool

## Usage

### マスタデータの投入

| option               | default | 内容                                   |
|----------------------| --- |--------------------------------------|
| --dry-run            | true | dry-runモードで実行する（データ変更は行わない）          |
| --verify             | true | データ投入後に全テーブル・全レコードのバリデーションチェックを行う    |
| --only-import-tables | [] | 指定したテーブルのみデータ投入を行う                   |
| --only-verify-tables | [] | 指定したテーブルのみ投入後のバリデーションチェックを行う |
| --skip-no-change     | true | CSVファイルに更新がないテーブルをスキップする             |

```bash
bundle exec master_data_tool import
```

は以下のオプションを指定したものと一緒

```bash
bundle exec thor master_data_tool import \
  --dry-run=true \
  --verify=true \
  --only-import-tables="" \
  --only-verify-tables="" \
  --skip-no-change=true
```

### ダンプ

| option                | default | 内容            |
|-----------------------|---------|---------------|
| --ignore-empty-table  | true    | 空のテーブルを無視する   |
| --ignore-tables       | []      | 指定したテーブルを無視する |
| --ignore-column-names | []      | 指定したカラムを無視する  |
| --verbose      | false   | 詳細表示          |

```bash
bundle exec master_data_tool dump
```

は以下のオプションを指定したものと一緒

```bash
bundle exec master_data_tool dump \
  --ignore-empty-table=true \
  --ignore-tables="" \
  --ignore-column-names="" \
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
export DB_PASSWORD=
```

- dockerでMySQLを立ち上げるたびにポートは変わるのでDB_PORTは都度設定する
  - direnvを使っているならば `direnv reload` すればいい

## rspec

```
bundle exec appraisal rails52 rspec
bundle exec appraisal rails61 rspec
bundle exec appraisal rails70 rspec
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/taka0125/master_data_tool.
