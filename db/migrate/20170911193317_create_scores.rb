class CreateScores < ActiveRecord::Migration[5.1]
  def change
    create_table :scores do |t|
      t.integer :game_id
      t.string :result
      t.string :game_status
      t.integer :home_team_total
      t.integer :away_team_total
      t.integer :home_team_rushing
      t.integer :away_team_rushing

      t.timestamps
    end
  end
end
