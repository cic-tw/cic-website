class Keyword < ActiveRecord::Base
  has_and_belongs_to_many :entries, -> { uniq }
  has_and_belongs_to_many :questions, -> { uniq }
  has_and_belongs_to_many :videos, -> { uniq }
  validates_presence_of :name, message: '請填寫關鍵字名稱'

  before_destroy { entries.clear }
  before_destroy { questions.clear }
  before_destroy { videos.clear }
end
