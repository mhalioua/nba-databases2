class AddColumnsToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :away_last_game, :integer
  	add_column :nbas, :away_next_game, :integer
  	add_column :nbas, :away_first_quarter, :integer
  	add_column :nbas, :away_second_quarter, :integer
  	add_column :nbas, :away_third_quarter, :integer
  	add_column :nbas, :away_forth_quarter, :integer
  	add_column :nbas, :away_ot_quarter, :integer

  	add_column :nbas, :home_last_game, :integer
  	add_column :nbas, :home_last_fly, :string
  	add_column :nbas, :home_next_game, :integer
  	add_column :nbas, :home_next_fly, :string
  	add_column :nbas, :home_first_quarter, :integer
  	add_column :nbas, :home_second_quarter, :integer
  	add_column :nbas, :home_third_quarter, :integer
  	add_column :nbas, :home_forth_quarter, :integer
  	add_column :nbas, :home_ot_quarter, :integer

  	add_column :nbas, :away_score, :integer
  	add_column :nbas, :home_score, :integer
  	add_column :nbas, :total_score, :integer

  	add_column :nbas, :first_point, :integer
  	add_column :nbas, :second_point, :integer
  	add_column :nbas, :total_point, :integer

  	add_column :nbas, :first_line, :float
  	add_column :nbas, :second_line, :float
  	add_column :nbas, :full_line, :float

  	add_column :nbas, :first_side, :float
  	add_column :nbas, :second_side, :float
  	add_column :nbas, :full_side, :float

  end
end
