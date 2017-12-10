class AddCountToTg < ActiveRecord::Migration[5.1]
  def change
  	add_column :tgs, :count, :integer
  	change_column  :players, :ortg, :float
  	change_column  :players, :drtg, :float
  end
end
