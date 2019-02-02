class AddTeamToCbbRecord < ActiveRecord::Migration[5.1]
  def change
    add_column :cbb_records, :cbb_team_id, :integer
  end
end
