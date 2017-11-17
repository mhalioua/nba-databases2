class AddGamedateToPlayer < ActiveRecord::Migration[5.1]
  def change
  	add_column :players, :game_date, :string
  end
end
