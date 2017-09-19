class AddHalfToScore < ActiveRecord::Migration[5.1]
  def change
    add_column :scores, :home_car, :string
    add_column :scores, :home_ave_car, :string
    add_column :scores, :home_pass_long, :string
    add_column :scores, :home_rush_long, :string
    add_column :scores, :home_c_att, :string
    add_column :scores, :home_ave_att, :string
    add_column :scores, :home_total_play, :string
    add_column :scores, :home_play_yard, :string
    add_column :scores, :home_sacks, :string
    add_column :scores, :away_car, :string
    add_column :scores, :away_ave_car, :string
    add_column :scores, :away_pass_long, :string
    add_column :scores, :away_rush_long, :string
    add_column :scores, :away_c_att, :string
    add_column :scores, :away_ave_att, :string
    add_column :scores, :away_total_play, :string
    add_column :scores, :away_play_yard, :string
    add_column :scores, :away_sacks, :string
  end
end
