class CreateAdSessions < ActiveRecord::Migration[4.2]
  def change
    create_table :ad_sessions do |t|
      t.string :name
      t.integer :ad_id
      t.date :date_start
      t.date :date_end

      t.timestamps null: false
    end
  end
end
