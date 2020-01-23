class AddIndicesToTables < ActiveRecord::Migration[5.1]
  def change
  	add_index :filters, :nba_id
  	add_index :filters, :index
  	add_index :filters, :year

  	add_index :nbas, :game_id
  	add_index :nbas, :home_abbr
  	add_index :nbas, :away_abbr
  	add_index :nbas, :total_point
  	add_index :nbas, :game_date
  	add_index :nbas, :home_team
  	add_index :nbas, :away_team

  	add_index :players, :team_abbr
  	add_index :players, :player_name
  	add_index :players, :game_date
  	add_index :players, :player_fullname

  	add_index :teams, :abbr

  	add_index :fullseasons, :homemore
  	add_index :fullseasons, :roadmore
  	add_index :fullseasons, :hometeam
  	add_index :fullseasons, :week
  	add_index :fullseasons, :awaylastfly
  	add_index :fullseasons, :awaynextfly
  	add_index :fullseasons, :roadlast
  	add_index :fullseasons, :roadnext
  	add_index :fullseasons, :homenext
  	add_index :fullseasons, :homelast
  	add_index :fullseasons, :homenextfly
  	add_index :fullseasons, :homelastfly

  	add_index :secondtravels, :hometeam
  	add_index :secondtravels, :week
  	add_index :secondtravels, :awaylastfly
  	add_index :secondtravels, :awaynextfly
  	add_index :secondtravels, :roadlast
  	add_index :secondtravels, :roadnext
  	add_index :secondtravels, :homenext
  	add_index :secondtravels, :homelast
  	add_index :secondtravels, :homenextfly
  	add_index :secondtravels, :homelastfly

  	add_index :refereestatics, :referee_one
  	add_index :refereestatics, :referee_two
  	add_index :refereestatics, :referee_three

  	add_index :referees, :referee_one
  	add_index :referees, :referee_two
  	add_index :referees, :referee_three

  end
end
