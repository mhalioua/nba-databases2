class AddSumToPlayerData < ActiveRecord::Migration[5.1]
  def change
  	add_column :player_data, :sum_to, :integer
  end
end
