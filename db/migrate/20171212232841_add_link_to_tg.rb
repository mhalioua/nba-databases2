class AddLinkToTg < ActiveRecord::Migration[5.1]
  def change
  	add_column :tgs, :player_link, :string
  	add_column :tgs, :player_fullname, :string

  	add_column :players, :player_link, :string
  	add_column :players, :player_fullname, :string
  end
end
