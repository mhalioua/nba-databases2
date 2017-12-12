class AddLinkToTg < ActiveRecord::Migration[5.1]
  def change
  	add_column :tgs, :player_link, :integer
  	add_column :tgs, :player_fullname, :integer
  end
end
