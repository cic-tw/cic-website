class CreateLegislatorCommittees < ActiveRecord::Migration[4.2]
  def change
    create_table :legislator_committees do |t|
      t.belongs_to :legislator
      t.belongs_to :ad_session
      t.belongs_to :committee
      t.boolean :convener
    end
  end
end

  
