class AddMoreIndices < ActiveRecord::Migration[5.1]
  def change
  	add_index :cbb_players, :birthdate

  	add_index :nba_players, :birthdate
  	
  	add_index :starters, :team
  	add_index :starters, :time
  	
  	add_index :players, :link
  	add_index :players, :mins

  	add_index :injuries, :team
  	add_index :injuries, :today

  	add_index :referees, :referee_one_last
  	add_index :referees, :referee_two_last
  	add_index :referees, :referee_three_last
  	add_index :referees, :referee_one_next
  	add_index :referees, :referee_two_next
  	add_index :referees, :referee_three_next	
  end
end
