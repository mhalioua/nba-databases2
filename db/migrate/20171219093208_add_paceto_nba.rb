class AddPacetoNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :pace, :float
  	add_column :nbas, :away_ortg, :float
  	add_column :nbas, :home_ortg, :float
  	add_column :nbas, :away_last_home, :integer
  	add_column :nbas, :away_next_home, :integer
  end
end
