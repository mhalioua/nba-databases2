class AddLinesToCbbGames < ActiveRecord::Migration[5.1]
  def change
    add_column :cbb_games, :full_opener_total, :string
    add_column :cbb_games, :full_opener_total, :string
  end
end
