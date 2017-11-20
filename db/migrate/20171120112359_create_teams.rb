class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
		t.string :team
		t.string :abbr
		t.float :rebound_current
		t.float :rebound_last_three
		t.float :rebound_last_one
		t.float :rebound_home
		t.float :rebound_away
		t.float :rebound_last

		t.float :possessions_current
		t.float :possessions_last_three
		t.float :possessions_last_one
		t.float :possessions_home
		t.float :possessions_away
		t.float :possessions_last
      	t.timestamps
    end
  end
end
