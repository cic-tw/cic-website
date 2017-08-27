class CreateIncantations < ActiveRecord::Migration[4.2]
  def change
    create_table :incantations do |t|
      t.string :title
      t.string :word
    end
  end
end
