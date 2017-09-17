class AddNumberToGames < ActiveRecord::Migration[5.1]
  def change
  	add_column :games, :home_number, :integer
    add_column :games, :away_number, :integer
  end
end
