class AddMinSumToPlayers < ActiveRecord::Migration[5.1]
  def change
  	add_column :players, :sum_mins, :integer
  end
end
