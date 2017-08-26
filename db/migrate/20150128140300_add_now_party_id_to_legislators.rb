class AddNowPartyIdToLegislators < ActiveRecord::Migration[4.2]
  def change
    add_column :legislators, :now_party_id, :integer
  end
end
