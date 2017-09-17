class AddGamestateToGames < ActiveRecord::Migration[5.1]
  def change
  	add_column :games, :game_state, :integer
  	add_column :games, :game_status, :string
  end
end
