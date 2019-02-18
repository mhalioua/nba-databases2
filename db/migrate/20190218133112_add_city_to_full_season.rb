class AddCityToFullSeason < ActiveRecord::Migration[5.1]
  def change
    add_column :fullseasons, :home_last_away, :integer
    add_column :fullseasons, :home_next_away, :integer

    add_column :fullseasons, :away_team_city, :string
    add_column :fullseasons, :home_team_city, :string

    add_column :fullseasons, :away_team_next_city, :string
    add_column :fullseasons, :home_team_next_city, :string
  end
end
