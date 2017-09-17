class AddKickedToGames < ActiveRecord::Migration[5.1]
  def change
  	add_column :games, :kicked, :string
  end
end
