class AddColumnsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :provider, :string
    add_column :users, :provider_uid, :string
  end
end
