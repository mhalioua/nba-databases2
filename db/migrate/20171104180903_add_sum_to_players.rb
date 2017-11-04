class AddSumToPlayers < ActiveRecord::Migration[5.1]
  def change
  	add_column :players, :sum_poss, :integer
  	add_column :players, :team_poss, :integer
  end
end
