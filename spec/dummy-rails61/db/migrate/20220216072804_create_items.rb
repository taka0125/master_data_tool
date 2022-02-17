class CreateItems < ActiveRecord::Migration[6.1]
  def self.up
    create_table :items do |t|
      t.string :field1, limit: 255, null: false
      t.string :field2, limit: 255, null: false
      t.string :field3, limit: 255, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end

  def self.down
    drop_table :items
  end
end
