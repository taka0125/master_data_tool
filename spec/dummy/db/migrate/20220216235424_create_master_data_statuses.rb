class CreateMasterDataStatuses < ActiveRecord::Migration[5.2]
  def self.up
    create_table :master_data_statuses do |t|
      t.string :name, limit: 255, null: false, comment: 'テーブル名'
      t.string :version, limit: 255, null: false, comment: 'ハッシュ値'
      t.datetime :created_at, null: false, comment: '作成日時'
      t.datetime :updated_at, null: false, comment: '更新日時'
    end

    add_index :master_data_statuses, %i[name], name: 'idx_master_data_statuses_1', unique: true
    add_index :master_data_statuses, %i[name version], name: 'idx_master_data_statuses_2'
  end

  def self.down
    drop_table :master_data_statuses
  end
end
