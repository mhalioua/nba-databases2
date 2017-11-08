class AddProrateToPlayers < ActiveRecord::Migration[5.1]
  def change
  	add_column :players, :prorate, :float
  end
end
