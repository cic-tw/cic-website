class CreateElections < ActiveRecord::Migration[4.2]
  def change
    create_table :elections do |t|
      t.integer :ad_id
      t.integer :legislator_id
      t.integer :party_id
      t.string :constituency

      t.timestamps
    end
  end
end
