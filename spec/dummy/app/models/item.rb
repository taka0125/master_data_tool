class Item < ApplicationRecord
  has_many :item_taggings
  has_many :item_tags, through: :item_taggings, source: :tag

  validates :field1,
            presence: true,
            length: { maximum: 10 }

  validates :field2,
            presence: true

  validates :field3,
            presence: true
end
