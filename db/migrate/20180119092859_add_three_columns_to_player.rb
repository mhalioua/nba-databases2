class AddThreeColumnsToPlayer < ActiveRecord::Migration[5.1]
  def change
  	add_column :players, :sum_or, :integer
  	add_column :players, :sum_stl, :integer
  	add_column :players, :sum_blk, :integer
  	add_column :players, :stlValue, :integer
  	add_column :players, :blkValue, :integer
  end
end
