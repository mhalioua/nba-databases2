class AddNewFieldToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :first_away_stl, :integer
  	add_column :nbas, :first_away_blk, :integer

  	add_column :nbas, :first_home_stl, :integer
  	add_column :nbas, :first_home_blk, :integer
  end
end
