class AddValuesToPlayers < ActiveRecord::Migration[5.1]
  def change
  	add_column :players, :mins, :integer
  	add_column :players, :fga, :integer
  	add_column :players, :fta, :integer
  	add_column :players, :toValue, :integer
  	add_column :players, :orValue, :integer
  end
end
