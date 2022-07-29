class ItemTagging < ApplicationRecord
  belongs_to :item, optional: false
  belongs_to :tag, optional: false
end
