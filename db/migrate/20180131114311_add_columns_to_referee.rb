class AddColumnsToReferee < ActiveRecord::Migration[5.1]
  def change
  	add_column :referees, :away_fga, :integer
  	add_column :referees, :home_fga, :integer
  	add_column :referees, :away_fta, :integer
  	add_column :referees, :home_fta, :integer
  	add_column :referees, :away_toValue, :integer
  	add_column :referees, :home_toValue, :integer
  	add_column :referees, :away_orValue, :integer
  	add_column :referees, :home_orValue, :integer
  	add_column :referees, :away_stl, :integer
  	add_column :referees, :home_stl, :integer
  	add_column :referees, :away_blk, :integer
  	add_column :referees, :home_blk, :integer
  	add_column :referees, :away_pf, :integer
  	add_column :referees, :home_pf, :integer
  end
end
