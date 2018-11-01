class AddBiggerToNbaDatabase < ActiveRecord::Migration[5.1]
  def change
    add_column :nba_databases, :first_half_bigger, :string
    add_column :nba_databases, :second_half_bigger, :string
    add_column :nba_databases, :fullgame_bigger, :string
  end
end
