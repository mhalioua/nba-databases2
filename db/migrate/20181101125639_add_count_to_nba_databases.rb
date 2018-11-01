class AddCountToNbaDatabases < ActiveRecord::Migration[5.1]
  def change
    add_column :nba_databases, :fg_total_count_2000, :integer
    add_column :nba_databases, :first_half_total_count_2000, :integer
    add_column :nba_databases, :second_half_total_count_2000, :integer
    add_column :nba_databases, :fg_total_count_1990, :integer
    add_column :nba_databases, :first_half_total_count_1990, :integer
    add_column :nba_databases, :second_half_total_count_1990, :integer
  end
end
