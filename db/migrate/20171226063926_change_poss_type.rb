class ChangePossType < ActiveRecord::Migration[5.1]
  def change
  	change_column :players, :poss, :float
  	change_column :players, :sum_poss, :float
   	change_column :players, :team_poss, :float
  end
end
