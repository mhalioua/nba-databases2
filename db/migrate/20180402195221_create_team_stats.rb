class CreateTeamStats < ActiveRecord::Migration[5.1]
  def change
    create_table :team_stats do |t|
      t.integer :nba_id
      t.string :team
      t.string :abbr

      t.float :possessions_current
      t.float :possessions_last_three
      t.float :possessions_last_one
      t.float :possessions_home
      t.float :possessions_away
      t.float :possessions_last

      t.float :rebound_current
      t.float :rebound_last_three
      t.float :rebound_last_one
      t.float :rebound_home
      t.float :rebound_away
      t.float :rebound_last

      t.float :steal_current
      t.float :steal_last_three
      t.float :steal_last_one
      t.float :steal_home
      t.float :steal_away
      t.float :steal_last

      t.float :block_current
      t.float :block_last_three
      t.float :block_last_one
      t.float :block_home
      t.float :block_away
      t.float :block_last

      t.float :turnover_current
      t.float :turnover_last_three
      t.float :turnover_last_one
      t.float :turnover_home
      t.float :turnover_away
      t.float :turnover_last

      t.float :record_won
      t.float :record_lost
      t.float :record_ppg
      t.float :record_opp
      t.float :record_diff

      t.float :opponentfirst_current
      t.float :opponentfirst_last_three
      t.float :opponentfirst_last_one
      t.float :opponentfirst_home
      t.float :opponentfirst_away
      t.float :opponentfirst_last

      t.float :opponentsecond_current
      t.float :opponentsecond_last_three
      t.float :opponentsecond_last_one
      t.float :opponentsecond_home
      t.float :opponentsecond_away
      t.float :opponentsecond_last

      t.float :first_current
      t.float :first_last_three
      t.float :first_last_one
      t.float :first_home
      t.float :first_away
      t.float :first_last

      t.float :second_current
      t.float :second_last_three
      t.float :second_last_one
      t.float :second_home
      t.float :second_away
      t.float :second_last

      t.timestamps
    end
  end
end
