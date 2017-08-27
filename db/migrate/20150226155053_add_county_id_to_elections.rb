class AddCountyIdToElections < ActiveRecord::Migration[4.2]
  def change
    add_column :elections, :county_id, :integer
  end
end
