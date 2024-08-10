class Tagging < ApplicationRecord
  include MasterDataTool::ActAsMasterData

  belongs_to :tag, optional: false
end
