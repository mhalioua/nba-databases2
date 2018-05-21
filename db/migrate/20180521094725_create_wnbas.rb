class CreateWnbas < ActiveRecord::Migration[5.1]
  def change
    create_table :wnbas do |t|
      t.string :home_team
      t.string :away_team
      t.integer :game_id
      t.string :game_date
      t.string :home_abbr
      t.string :away_abbr

      t.string :year
      t.string :date
      t.string :time
      t.string :week

      t.integer :away_last_game
      t.integer :away_next_game
      t.integer :away_first_quarter
      t.integer :away_second_quarter
      t.integer :away_third_quarter
      t.integer :away_forth_quarter
      t.integer :away_ot_quarter

      t.integer :home_last_game
      t.integer :home_next_game
      t.integer :home_first_quarter
      t.integer :home_second_quarter
      t.integer :home_third_quarter
      t.integer :home_forth_quarter
      t.integer :home_ot_quarter

      t.integer :away_fga
      t.integer :away_fta
      t.integer :away_toValue
      t.integer :away_orValue

      t.integer :home_fga
      t.integer :home_fta
      t.integer :home_toValue
      t.integer :home_orValue

      t.integer :away_score
      t.integer :home_score
      t.integer :total_score

      t.integer :first_point
      t.integer :second_point
      t.integer :total_point

      t.float :first_opener_side
      t.float :first_closer_side
      t.float :first_opener_total
      t.float :first_closer_total
      t.float :second_opener_side
      t.float :second_closer_side
      t.float :second_opener_total
      t.float :second_closer_total
      t.float :full_opener_side
      t.float :full_closer_side
      t.float :full_opener_total
      t.float :full_closer_total

      t.integer :home_fga_first
      t.integer :home_fgm_first
      t.integer :home_fga_second
      t.integer :home_fgm_second
      t.integer :home_pta_first
      t.integer :home_ptm_first
      t.integer :home_pta_second
      t.integer :home_ptm_second
      t.integer :home_or_first
      t.integer :home_or_second
      t.integer :home_fta_first
      t.integer :home_fta_second
      t.integer :home_ftm_first
      t.integer :home_ftm_second
      t.integer :home_to_first
      t.integer :home_to_second
      t.integer :home_foul_first
      t.integer :home_foul_second
      t.integer :away_fga_first
      t.integer :away_fgm_first
      t.integer :away_fga_second
      t.integer :away_fgm_second
      t.integer :away_pta_first
      t.integer :away_ptm_first
      t.integer :away_pta_second
      t.integer :away_ptm_second
      t.integer :away_or_first
      t.integer :away_or_second
      t.integer :away_fta_first
      t.integer :away_fta_second
      t.integer :away_ftm_first
      t.integer :away_ftm_second
      t.integer :away_to_first
      t.integer :away_to_second
      t.integer :away_foul_first
      t.integer :away_foul_second

      t.string :est_time
      t.integer :game_count

      t.timestamps
    end
  end
end
