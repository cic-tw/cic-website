class AddPositiveToIncantations < ActiveRecord::Migration[4.2]
  def change
    add_column :incantations, :positive, :boolean, default: true
  end
end
