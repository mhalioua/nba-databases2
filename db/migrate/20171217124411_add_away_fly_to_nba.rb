class AddAwayFlyToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :away_last_fly, :string
  	add_column :nbas, :away_next_fly, :string
  end
end
