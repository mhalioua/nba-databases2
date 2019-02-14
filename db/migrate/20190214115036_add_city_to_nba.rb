class AddCityToNba < ActiveRecord::Migration[5.1]
  def change
    add_column :nbas, :away_team_city, :string
    add_column :nbas, :home_team_city, :string
  end
end
