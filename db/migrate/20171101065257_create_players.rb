class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
        t.integer :team_abbr
		    t.string :player_name
      	t.string :position
      	t.string :possession
      	t.integer :ortg
      	t.integer :drtg
      	t.timestamps
    end
  end
end
