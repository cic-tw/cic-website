class Keyword < ApplicationRecord
  has_and_belongs_to_many :entries, index: { unique: true }
  has_and_belongs_to_many :interpellations, index: { unique: true }
  has_and_belongs_to_many :videos, index: { unique: true }
  validates_presence_of :name, message: '請填寫關鍵字名稱'

  before_destroy { entries.clear }
  before_destroy { interpellations.clear }
  before_destroy { videos.clear }
end
