class AddAwayOtToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :home_last_ot, :string
  	add_column :nbas, :away_last_ot, :string
  end
end
