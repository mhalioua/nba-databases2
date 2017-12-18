class AddmoreToTeam < ActiveRecord::Migration[5.1]
  def change
	rename_column :teams, :order_one_sev, :order_one_seventeen
	rename_column :teams, :order_two_sev, :order_two_seventeen
	rename_column :teams, :order_thr_sev, :order_thr_seventeen
	
	rename_column :teams, :order_one_six, :order_one_sixteen
	rename_column :teams, :order_two_six, :order_two_sixteen
	rename_column :teams, :order_thr_six, :order_thr_sixteen

  	add_column :teams, :order_one_one, :integer
	add_column :teams, :order_two_one, :integer
	add_column :teams, :order_thr_one, :integer

	add_column :teams, :order_one_two, :integer
	add_column :teams, :order_two_two, :integer
	add_column :teams, :order_thr_two, :integer

	add_column :teams, :order_one_thr, :integer
	add_column :teams, :order_two_thr, :integer
	add_column :teams, :order_thr_thr, :integer

	add_column :teams, :order_one_four, :integer
	add_column :teams, :order_two_four, :integer
	add_column :teams, :order_thr_four, :integer

	add_column :teams, :order_one_five, :integer
	add_column :teams, :order_two_five, :integer
	add_column :teams, :order_thr_fore, :integer

	add_column :teams, :order_one_six, :integer
	add_column :teams, :order_two_six, :integer
	add_column :teams, :order_thr_six, :integer
	
	add_column :teams, :order_one_seven, :integer
	add_column :teams, :order_two_seven, :integer
	add_column :teams, :order_thr_seven, :integer

	add_column :teams, :order_one_eight, :integer
	add_column :teams, :order_two_eight, :integer
	add_column :teams, :order_thr_eight, :integer

	add_column :teams, :order_one_nine, :integer
	add_column :teams, :order_two_nine, :integer
	add_column :teams, :order_thr_nine, :integer

	add_column :teams, :order_one_ten, :integer
	add_column :teams, :order_two_ten, :integer
	add_column :teams, :order_thr_ten, :integer

	add_column :teams, :order_one_eleven, :integer
	add_column :teams, :order_two_eleven, :integer
	add_column :teams, :order_thr_eleven, :integer

	add_column :teams, :order_one_twelve, :integer
	add_column :teams, :order_two_twelve, :integer
	add_column :teams, :order_thr_twelve, :integer

	add_column :teams, :order_one_thirteen, :integer
	add_column :teams, :order_two_thirteen, :integer
	add_column :teams, :order_thr_thirteen, :integer

	add_column :teams, :order_one_forteen, :integer
	add_column :teams, :order_two_forteen, :integer
	add_column :teams, :order_thr_forteen, :integer

	add_column :teams, :order_one_fifteen, :integer
	add_column :teams, :order_two_fifteen, :integer
	add_column :teams, :order_thr_fifteen, :integer
  end
end
