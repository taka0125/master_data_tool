class CreateTags < ActiveRecord::Migration[6.1]
  def self.up
    create_table :tags do |t|
      t.string :name, limit: 255, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end

  def self.down
    drop_table :tags
  end
end
