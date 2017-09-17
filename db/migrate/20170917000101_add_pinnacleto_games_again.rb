class AddPinnacletoGamesAgain < ActiveRecord::Migration[5.1]
  def change
  	add_column :games, :home_2nd_pinnacle, :string
  	add_column :games, :away_2nd_pinnacle, :string
  end
end
