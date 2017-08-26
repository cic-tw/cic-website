class AddTargetToVideos < ActiveRecord::Migration[4.2]
  def change
    add_column :videos, :target, :string
  end
end
