class AddPtsToPlayers < ActiveRecord::Migration[5.1]
  def change
  	add_column :players, :ptsValue, :integer
  end
end
