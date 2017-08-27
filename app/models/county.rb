class County < ApplicationRecord
  has_many :districts
  has_many :elections
  has_many :legislators, through: :elections
end
