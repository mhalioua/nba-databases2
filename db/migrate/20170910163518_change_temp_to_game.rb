class ChangeTempToGame < ActiveRecord::Migration[5.1]
  def change
  	remove_column :games, :game_date, :string
  	add_column :games, :game_date, :datetime
  end
end
