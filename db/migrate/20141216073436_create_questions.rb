class CreateQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :questions do |t|
      t.string :title
      t.text :content
      t.integer :user_id
      t.integer :committee_id
      t.integer :ad_session_id
      t.text :meeting_description
      t.string :ivod_url
      t.time :time_start
      t.time :time_end
      t.string :target
      t.date :date
      t.text :comment
      t.string :user_ip
      t.boolean :published, default: true

      t.timestamps
    end
  end
end
