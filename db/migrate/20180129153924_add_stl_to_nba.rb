class AddStlToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :away_stl, :integer
  	add_column :nbas, :away_blk, :integer

  	add_column :nbas, :home_stl, :integer
  	add_column :nbas, :home_blk, :integer
  end
end
