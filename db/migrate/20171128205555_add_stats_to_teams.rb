class AddStatsToTeams < ActiveRecord::Migration[5.1]
  def change
	add_column :teams, :steal_current, :float
	add_column :teams, :steal_last_three, :float
	add_column :teams, :steal_last_one, :float
	add_column :teams, :steal_home, :float
	add_column :teams, :steal_away, :float
	add_column :teams, :steal_last, :float

	add_column :teams, :block_current, :float
	add_column :teams, :block_last_three, :float
	add_column :teams, :block_last_one, :float
	add_column :teams, :block_home, :float
	add_column :teams, :block_away, :float
	add_column :teams, :block_last, :float

	add_column :teams, :turnover_current, :float
	add_column :teams, :turnover_last_three, :float
	add_column :teams, :turnover_last_one, :float
	add_column :teams, :turnover_home, :float
	add_column :teams, :turnover_away, :float
	add_column :teams, :turnover_last, :float

	add_column :teams, :record_won, :float
	add_column :teams, :record_lost, :float
	add_column :teams, :record_ppg, :float
	add_column :teams, :record_opp, :float
	add_column :teams, :record_diff, :float

	add_column :teams, :opponentfirst_current, :float
	add_column :teams, :opponentfirst_last_three, :float
	add_column :teams, :opponentfirst_last_one, :float
	add_column :teams, :opponentfirst_home, :float
	add_column :teams, :opponentfirst_away, :float
	add_column :teams, :opponentfirst_last, :float

	add_column :teams, :opponentsecond_current, :float
	add_column :teams, :opponentsecond_last_three, :float
	add_column :teams, :opponentsecond_last_one, :float
	add_column :teams, :opponentsecond_home, :float
	add_column :teams, :opponentsecond_away, :float
	add_column :teams, :opponentsecond_last, :float

	add_column :teams, :first_current, :float
	add_column :teams, :first_last_three, :float
	add_column :teams, :first_last_one, :float
	add_column :teams, :first_home, :float
	add_column :teams, :first_away, :float
	add_column :teams, :first_last, :float

	add_column :teams, :second_current, :float
	add_column :teams, :second_last_three, :float
	add_column :teams, :second_last_one, :float
	add_column :teams, :second_home, :float
	add_column :teams, :second_away, :float
	add_column :teams, :second_last, :float
  end
end
