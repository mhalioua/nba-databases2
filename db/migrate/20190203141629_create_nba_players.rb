class CreateNbaPlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :nba_players do |t|
      t.string :team_name
      t.string :player_name
      t.string :link
      t.string :birthdate

      t.timestamps
    end
  end
end
