class Election < ActiveRecord::Base
  belongs_to :ad
  belongs_to :legislator
  belongs_to :party
  belongs_to :county
  has_and_belongs_to_many :districts, -> { uniq }
  validates_presence_of :ad_id, :legislator_id, :party_id, :constituency

  default_scope { order(ad_id: :asc).order(id: :asc) }
  scope :ordered_by_vote_date, -> { joins(:ad).unscoped.order('ads.vote_date ASC') }

  before_destroy { districts.clear }

  def district_names
    districts.map { |d| d.name }
  end
end
