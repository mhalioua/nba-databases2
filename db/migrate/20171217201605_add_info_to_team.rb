class AddInfoToTeam < ActiveRecord::Migration[5.1]
  def change
  	add_column :teams, :timezone, :integers
	add_column :teams, :order_one, :integer
	add_column :teams, :order_two, :integer
	add_column :teams, :order_thr, :integer
  end
end
