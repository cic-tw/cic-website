class AddKindToCommittees < ActiveRecord::Migration[4.2]
  def change
    add_column :committees, :kind, :string
  end
end
