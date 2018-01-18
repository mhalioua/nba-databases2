class AddAvgToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :avg_fg_road, :float
  	add_column :nbas, :avg_fg_home, :float
  	add_column :nbas, :avg_fg_total, :float
  	add_column :nbas, :avg_first_road, :float
  	add_column :nbas, :avg_first_home, :float
  	add_column :nbas, :avg_first_total, :float
  	add_column :nbas, :avg_second_road, :float
  	add_column :nbas, :avg_second_home, :float
  	add_column :nbas, :avg_second_total, :float
  	add_column :nbas, :avg_count, :integer
  end
end
