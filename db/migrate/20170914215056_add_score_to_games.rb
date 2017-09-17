class AddScoreToGames < ActiveRecord::Migration[5.1]
  def change
  	add_column :games, :home_result, :string
  	add_column :games, :away_result, :string
  	remove_column :games, :result, :string
  end
end
