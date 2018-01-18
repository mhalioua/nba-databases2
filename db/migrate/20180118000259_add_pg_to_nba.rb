class AddPgToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :pg_away_one_name, :string
  	add_column :nbas, :pg_away_one_min, :integer
  	add_column :nbas, :pg_away_two_name, :string
  	add_column :nbas, :pg_away_two_min, :integer
  	add_column :nbas, :pg_away_three_name, :string
  	add_column :nbas, :pg_away_three_min, :integer

  	add_column :nbas, :pg_home_one_name, :string
  	add_column :nbas, :pg_home_one_min, :integer
  	add_column :nbas, :pg_home_two_name, :string
  	add_column :nbas, :pg_home_two_min, :integer
  	add_column :nbas, :pg_home_three_name, :string
  	add_column :nbas, :pg_home_three_min, :integer
  	add_column :nbas, :away_fg_percent, :string
  	add_column :nbas, :home_fg_percent, :string
  end
end
