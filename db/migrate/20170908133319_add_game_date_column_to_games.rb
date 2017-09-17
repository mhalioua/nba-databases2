class AddGameDateColumnToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :game_date, :string
  end
end
