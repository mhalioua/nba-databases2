class CreateCbbPlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :cbb_players do |t|
      t.integer :team_id
      t.string :player_name
      t.string :link

      t.string :ave_mins
      t.string :class

      t.string :birthdate

      t.timestamps
    end
  end
end
