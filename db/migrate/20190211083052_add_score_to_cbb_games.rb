class AddScoreToCbbGames < ActiveRecord::Migration[5.1]
  def change
    add_column :cbb_games, :away_first_quarter, :integer
    add_column :cbb_games, :home_first_quarter, :integer
    add_column :cbb_games, :away_second_quarter, :integer
    add_column :cbb_games, :home_second_quarter, :integer
    add_column :cbb_games, :away_ot_quarter, :integer
    add_column :cbb_games, :home_ot_quarter, :integer
    add_column :cbb_games, :away_score, :integer
    add_column :cbb_games, :home_score, :integer
    add_column :cbb_games, :full_opener_side, :string
    add_column :cbb_games, :full_closer_side, :string
  end
end
