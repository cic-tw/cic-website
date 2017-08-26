class CreateDistricts < ActiveRecord::Migration[4.2]
  def change
    create_table :districts do |t|
      t.integer :county_id
      t.string :name
    end
  end
end
