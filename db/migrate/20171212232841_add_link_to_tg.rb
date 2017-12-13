class AddLinkToTg < ActiveRecord::Migration[5.1]
  def change
  	change_column :tgs, :player_link, :string
  	change_column :tgs, :player_fullname, :string

  	add_column :players, :player_link, :string
  	add_column :players, :player_fullname, :string
  end
end
