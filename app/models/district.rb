class District < ApplicationRecord
  belongs_to :county
  has_and_belongs_to_many :elections, index: { unique: true }
  has_many :legislators, through: :elections

  before_destroy { elections.clear }
end
