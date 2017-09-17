class AddGameIdColumnToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :game_id, :integer
  end
end
