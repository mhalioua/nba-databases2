class AddPosstoNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :away_mins, :integer
  	add_column :nbas, :away_fga, :integer
  	add_column :nbas, :away_fta, :integer
  	add_column :nbas, :away_toValue, :integer
  	add_column :nbas, :away_orValue, :integer

  	add_column :nbas, :home_mins, :integer
  	add_column :nbas, :home_fga, :integer
  	add_column :nbas, :home_fta, :integer
  	add_column :nbas, :home_toValue, :integer
  	add_column :nbas, :home_orValue, :integer
  end
end
