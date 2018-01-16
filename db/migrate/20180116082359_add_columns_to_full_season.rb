class AddColumnsToFullSeason < ActiveRecord::Migration[5.1]
  def change
  	add_column :fullseasons, :offset_one, :float
	add_column :fullseasons, :offset_two, :float
	add_column :fullseasons, :firstvalue, :float
	add_column :fullseasons, :secondvalue, :float
	add_column :fullseasons, :totalvalue, :float
  end
end
