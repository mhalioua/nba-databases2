class CreateNbaDatabases < ActiveRecord::Migration[5.1]
  def change
    create_table :nba_databases do |t|
      t.integer :year
      t.string :date
      t.string :time
      t.string :week
      t.string :tv1
      t.string :tv2
      t.integer :count
      t.string :away_is_last_game_home
      t.integer :away_last
      t.integer :away_next
      t.string :away_is_next_game_home
      t.string :away_team
      t.integer :away_win_rank
      t.integer :away_true
      t.integer :away_ppg_rank
      t.integer :away_oppppg_rank
      t.string :from
      t.string :to
      t.integer :away_first_quarter
      t.integer :away_second_quarter
      t.integer :away_first_half
      t.integer :away_third_quarter
      t.integer :away_forth_quarter
      t.integer :away_ot
      t.integer :away_second_half
      t.integer :away_next
      t.string :home_is_last_game_home
      t.integer :home_last
      t.string :home_is_next_game_home
      t.string :home_team
      t.integer :home_win_rank
      t.integer :home_true
      t.integer :home_ppg_rank
      t.integer :home_oppppg_rank
      t.string :timezone
      t.integer :home_first_quarter
      t.integer :home_second_quarter
      t.integer :home_first_half
      t.integer :home_third_quarter
      t.integer :home_forth_quarter
      t.integer :home_second_half
      t.integer :home_ot
      t.integer :lead
      t.integer :three_rd
      t.integer :final
      t.integer :true_two_h
      t.integer :four_th
      t.integer :road
      t.integer :home
      t.integer :total
      t.integer :first_half_point
      t.integer :second_half_point
      t.integer :total_point
      t.string :first_line_string
      t.string :second_line_string
      t.string :total_line_string
      t.float :first_half_line_total
      t.float :second_half_line_total
      t.float :fullgame_line_total
      t.float :first_half_side
      t.float :second_half_side
      t.float :xxx
      t.float :fullgame_side
      t.string :did_home_team_play_over_time_last_game
      t.string :did_road_team_play_over_time_last_game
      t.float :pace
      t.float :away_ortg
      t.float :home_ortg
      t.integer :away_last_home
      t.integer :away_next_home
      t.float :first_half_offset
      t.float :second_half_offset
      t.float :first_half_points
      t.float :second_half_points
      t.float :total_points

      t.float :fg_road_2000
      t.float :fg_home_2000
      t.float :fg_diff_2000
      t.integer :fg_count_2000

      t.float :fg_road_1990
      t.float :fg_home_1990
      t.float :fg_diff_1990
      t.integer :fg_count_1990

      t.float :first_half_road_2000
      t.float :first_half_home_2000
      t.float :first_half_diff_2000
      t.integer :first_half_count_2000

      t.float :first_half_road_1990
      t.float :first_half_home_1990
      t.float :first_half_diff_1990
      t.integer :first_half_count_1990

      t.float :second_half_road_2000
      t.float :second_half_home_2000
      t.float :second_half_diff_2000
      t.integer :second_half_count_2000

      t.float :second_half_road_1990
      t.float :second_half_home_1990
      t.float :second_half_diff_1990
      t.integer :second_half_count_1990

      t.float :fg_total_pt_2000
      t.float :fg_total_line_2000
      t.float :fg_total_diff_2000
      t.float :first_half_total_pt_2000
      t.float :first_half_total_line_2000
      t.float :first_half_total_diff_2000
      t.float :second_half_total_pt_2000
      t.float :second_half_total_line_2000
      t.float :second_half_total_diff_2000

      t.float :fg_total_pt_1990
      t.float :fg_total_line_1990
      t.float :fg_total_diff_1990
      t.float :first_half_total_pt_1990
      t.float :first_half_total_line_1990
      t.float :first_half_total_diff_1990
      t.float :second_half_total_pt_1990
      t.float :second_half_total_line_1990
      t.float :second_half_total_diff_1990
      t.timestamps
    end
  end
end
