class AddCoulmnToWnba < ActiveRecord::Migration[5.1]
  def change
  	add_column :wnbas, :home_team_timezone, :string
    add_column :wnbas, :away_team_timezone, :string

    add_column :wnbas, :away_last_game_city, :string
    add_column :wnbas, :away_next_game_city, :string
    add_column :wnbas, :home_last_game_city, :string
    add_column :wnbas, :home_next_game_city, :string
    add_column :wnbas, :away_last_game_home, :string
    add_column :wnbas, :away_next_game_home, :string
    add_column :wnbas, :home_last_game_home, :string
    add_column :wnbas, :home_next_game_home, :string
  end
end
