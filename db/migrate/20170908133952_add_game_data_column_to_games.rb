class AddGameDataColumnToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :game_type, :string
    add_column :games, :week_index, :integer
  end
end
