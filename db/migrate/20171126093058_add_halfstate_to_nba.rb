class AddHalfstateToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :first_away_fga, :integer
  	add_column :nbas, :first_away_fta, :integer
  	add_column :nbas, :first_away_toValue, :integer
  	add_column :nbas, :first_away_orValue, :integer

  	add_column :nbas, :first_home_fga, :integer
  	add_column :nbas, :first_home_fta, :integer
  	add_column :nbas, :first_home_toValue, :integer
  	add_column :nbas, :first_home_orValue, :integer
  end
end
