class AddFgToFullseason < ActiveRecord::Migration[5.1]
  def change
	add_column :fullseasons, :referee_one, :string
	add_column :fullseasons, :referee_one_last, :integer
	add_column :fullseasons, :referee_one_next, :integer
	add_column :fullseasons, :referee_two, :string
	add_column :fullseasons, :referee_two_last, :integer
	add_column :fullseasons, :referee_two_next, :integer
	add_column :fullseasons, :referee_three, :string
	add_column :fullseasons, :referee_three_last, :integer
	add_column :fullseasons, :referee_three_next, :integer
	add_column :fullseasons, :pg_away_one_name, :string
	add_column :fullseasons, :pg_away_one_min, :integer
	add_column :fullseasons, :pg_away_two_name, :string
	add_column :fullseasons, :pg_away_two_min, :integer
	add_column :fullseasons, :pg_away_three_name, :string
	add_column :fullseasons, :pg_away_three_min, :integer
	add_column :fullseasons, :pg_home_one_name, :string
	add_column :fullseasons, :pg_home_one_min, :integer
	add_column :fullseasons, :pg_home_two_name, :string
	add_column :fullseasons, :pg_home_two_min, :integer
	add_column :fullseasons, :pg_home_three_name, :string
	add_column :fullseasons, :pg_home_three_min, :integer
	add_column :fullseasons, :away_fg_percent, :float
	add_column :fullseasons, :home_fg_percent, :float
	add_column :fullseasons, :avg_fg_road, :float
	add_column :fullseasons, :avg_fg_home, :float
	add_column :fullseasons, :avg_fg_total, :float
	add_column :fullseasons, :avg_first_road, :float
	add_column :fullseasons, :avg_first_home, :float
	add_column :fullseasons, :avg_first_total, :float
	add_column :fullseasons, :avg_second_road, :float
	add_column :fullseasons, :avg_second_home, :float
	add_column :fullseasons, :avg_second_total, :float
	add_column :fullseasons, :avg_count, :integer

  end
end
