class Changeweektoday < ActiveRecord::Migration[5.1]
  def change
  	change_column :games, :week_index, :string
  end
end
