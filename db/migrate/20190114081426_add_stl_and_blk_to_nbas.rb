class AddStlAndBlkToNbas < ActiveRecord::Migration[5.1]
  def change
    add_column :nbas, :home_stl_first, :string
    add_column :nbas, :home_blk_first, :string
    add_column :nbas, :home_stl_second, :string
    add_column :nbas, :home_blk_second, :string

    add_column :nbas, :away_stl_first, :string
    add_column :nbas, :away_blk_first, :string
    add_column :nbas, :away_stl_second, :string
    add_column :nbas, :away_blk_second, :string
  end
end
