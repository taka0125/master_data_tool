class Tag < ApplicationRecord
  include MasterDataTool::ActAsMasterData

  validates :name,
            presence: true
end
