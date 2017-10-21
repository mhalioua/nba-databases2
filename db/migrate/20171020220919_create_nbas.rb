class CreateNbas < ActiveRecord::Migration[5.1]
  def change
    create_table :nbas do |t|
		t.string :home_team
      	t.string :away_team
      	t.integer :game_id
      	t.string :game_date
      	t.string :home_abbr
      	t.string :away_abbr
      	t.timestamps
    end
  end
end
