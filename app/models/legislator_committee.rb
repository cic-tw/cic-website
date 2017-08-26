class LegislatorCommittee < ApplicationRecord
  belongs_to :legislator
  belongs_to :committee
  belongs_to :ad_session
  has_one :ccw_legislator_datum
end
