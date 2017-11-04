class AddStateToPlayers < ActiveRecord::Migration[5.1]
  def change
  	add_column :players, :state, :integer
  	add_column :players, :poss, :integer
  end
end
