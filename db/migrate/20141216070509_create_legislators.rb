class CreateLegislators < ActiveRecord::Migration[4.2]
  def change
    create_table :legislators do |t|
      t.string :name
      t.text :description
      t.string :image
      t.boolean :in_office

      t.timestamps
    end
  end
end
