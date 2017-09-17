class AddAbbrToGames < ActiveRecord::Migration[5.1]
  def change
  	add_column :games, :home_abbr, :string
  	add_column :games, :away_abbr, :string
  end
end
