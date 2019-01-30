class CreateCbbGames < ActiveRecord::Migration[5.1]
  def change
    create_table :cbb_games do |t|
      t.integer :game_id
      t.string :game_date
      t.string :home_team
      t.string :away_team
      t.string :home_abbr
      t.string :away_abbr

      t.timestamps
    end
  end
end
