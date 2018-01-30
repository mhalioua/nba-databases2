class AddPfToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :first_away_pf, :integer
  	add_column :nbas, :first_home_pf, :integer
  	add_column :nbas, :away_pf, :integer
  	add_column :nbas, :home_pf, :integer

  	add_column :players, :sum_pf, :integer
  	add_column :players, :pfValue, :integer
  	add_column :player_data, :sum_pf, :integer
  	add_column :player_data, :pfValue, :integer
  end
end
