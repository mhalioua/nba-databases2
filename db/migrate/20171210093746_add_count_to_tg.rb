class AddCountToTg < ActiveRecord::Migration[5.1]
  def change
  	add_column :tgs, :count, :integer
  	change_column  :player, :ortg, :float
  	change_column  :player, :drtg, :float
  end
end
