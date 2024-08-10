class ItemTagging < ApplicationRecord
  include MasterDataTool::ActAsMasterData

  belongs_to :item, optional: false
  belongs_to :tag, optional: false
end
