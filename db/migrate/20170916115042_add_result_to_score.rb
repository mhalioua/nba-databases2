class AddResultToScore < ActiveRecord::Migration[5.1]
  def change
  	remove_column :games, :home_result, :string
  	remove_column :games, :away_result, :string
  	add_column :scores, :home_result, :string
  	add_column :scores, :away_result, :string
  end
end
