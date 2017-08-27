class AddRegularToAdSessions < ActiveRecord::Migration[4.2]
  def change
    add_column :ad_sessions, :session, :integer
    add_column :ad_sessions, :regular, :boolean
  end
end
