class Tagging < ApplicationRecord
  belongs_to :tag, optional: false
end
