# CLAUDE.md

このファイルは、このリポジトリで作業する Claude Code (claude.ai/code) へのガイダンスを提供します。

## コマンド

```bash
# 初回セットアップ（Docker + DB + migrate）
make setup

# テスト実行
make ruby/rspec
bundle exec rspec

# 単一テストファイル・行番号指定
bundle exec rspec spec/master_data_tool/import/executor_spec.rb
bundle exec rspec spec/master_data_tool/import/executor_spec.rb:123

# 複数 ActiveRecord バージョンでテスト
bundle exec appraisal activerecord7.2 rspec
bundle exec appraisal activerecord8.0 rspec
bundle exec appraisal activerecord8.1 rspec

# コンテナ内 bash
make ruby/bash
```

## 注意事項

- `.envrc` で `DB_PORT` を動的設定しているため、`direnv allow` または `source .envrc` が必要
- テスト対象マトリクス: Ruby 3.3/3.4/4.0 × ActiveRecord 7.2/8.0/8.1
- 型定義は `sig/` に配置。`sig_generated/` は自動生成のため編集不要

## アーキテクチャ上の重要な決定

- **差分管理**: `master_data_statuses` テーブルにCSVのハッシュ値を保存し、変更がない場合はスキップ
- **Dry-run**: トランザクション内で処理し最後にロールバックする実装
- **テスト用ダミーアプリ**: `spec/dummy/` に Item/Tag/Tagging モデルを配置。スキーマは ridgepole（`spec/dummy/db/Schemafile`）で管理
