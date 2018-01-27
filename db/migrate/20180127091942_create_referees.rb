class CreateReferees < ActiveRecord::Migration[5.1]
  def change
    create_table :referees do |t|
	    t.integer :year
	    t.string :date
	    t.string :time
	    t.string :week
	    t.string :awaylastfly
	    t.integer :roadlast
	    t.integer :roadnext
	    t.string :awaynextfly
	    t.string :roadteam
	    t.integer :away_win_rank
	    t.integer :away_ppg_rank
	    t.integer :away_oppppg_rank
	    t.string :roadmore
	    t.integer :roadfirst
	    t.integer :roadsecond
	    t.integer :roadfirsthalf
	    t.integer :roadthird
	    t.integer :roadforth
	    t.integer :roadot
	    t.integer :homenext
	    t.string :homenextfly
	    t.integer :homelast
	    t.string :homelastfly
	    t.string :hometeam
	    t.integer :home_win_rank
	    t.integer :home_ppg_rank
	    t.integer :home_oppppg_rank
	    t.string :homemore
	    t.integer :homefirst
	    t.integer :homesecond
	    t.integer :homefirsthalf
	    t.integer :homethird
	    t.integer :homeforth
	    t.integer :homeot
	    t.integer :homediff
	    t.integer :roadtotal
	    t.integer :hometotal
	    t.integer :total
	    t.float :tp_1h
	    t.float :tp_2h
	    t.float :tp_fg
	    t.integer :firstpoint
	    t.integer :secondpoint
	    t.integer :totalpoint
	    t.float :firstlinetotal
	    t.float :secondlinetotal
	    t.float :fglinetotal
	    t.float :firstside
	    t.float :secondside
	    t.float :fgside
	    t.string :hometeamlastgame
	    t.string :roadteamlastgame
	    t.float :pace
	    t.float :away_ortg
	    t.float :home_ortg
	    t.integer :away_last_home
	    t.integer :away_next_home
	    t.string :referee_one
		t.integer :referee_one_last
		t.integer :referee_one_next
		t.string :referee_two
		t.integer :referee_two_last
		t.integer :referee_two_next
		t.string :referee_three
		t.integer :referee_three_last
		t.integer :referee_three_next
		t.string :pg_away_one_name
		t.integer :pg_away_one_min
		t.string :pg_away_two_name
		t.integer :pg_away_two_min
		t.string :pg_away_three_name
		t.integer :pg_away_three_min
		t.string :pg_home_one_name
		t.integer :pg_home_one_min
		t.string :pg_home_two_name
		t.integer :pg_home_two_min
		t.string :pg_home_three_name
		t.integer :pg_home_three_min
		t.float :away_fg_percent
		t.float :home_fg_percent
		t.float :avg_fg_road
		t.float :avg_fg_home
		t.float :avg_fg_total
		t.float :avg_first_road
		t.float :avg_first_home
		t.float :avg_first_total
		t.float :avg_second_road
		t.float :avg_second_home
		t.float :avg_second_total
		t.integer :avg_count

      t.timestamps
    end
  end
end
