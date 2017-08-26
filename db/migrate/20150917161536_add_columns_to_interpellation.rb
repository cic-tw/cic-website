class AddColumnsToInterpellation < ActiveRecord::Migration[4.2]
  def change
    add_column :interpellations, :interpellation_type, :string
    add_column :interpellations, :record_url, :string
  end
end
