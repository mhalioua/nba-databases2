class AddPinnacletoGames < ActiveRecord::Migration[5.1]
  def change
  	add_column :games, :home_pinnacle, :string
  	add_column :games, :away_pinnacle, :string
  end
end
