class AddInfoToTeam < ActiveRecord::Migration[5.1]
  def change
  	add_column :teams, :timezone, :integer
	add_column :teams, :order_one_sev, :integer
	add_column :teams, :order_two_sev, :integer
	add_column :teams, :order_thr_sev, :integer
	add_column :teams, :order_one_six, :integer
	add_column :teams, :order_two_six, :integer
	add_column :teams, :order_thr_six, :integer
  end
end
