class AddHeightToPlayers < ActiveRecord::Migration[5.1]
  def change
  	add_column :players, :height, :string
  end
end
