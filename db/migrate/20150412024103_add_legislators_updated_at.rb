class AddLegislatorsUpdatedAt < ActiveRecord::Migration[4.2]
  def change
    add_column :legislators, :updated_at, :datetime, null: false, default: Time.now
  end
end
