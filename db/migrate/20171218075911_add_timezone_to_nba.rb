class AddTimezoneToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :home_timezone, :string
  	add_column :nbas, :home_win_rank, :integer
  	add_column :nbas, :home_ppg_rank, :integer
  	add_column :nbas, :home_oppppg_rank, :integer
  	add_column :nbas, :away_timezone, :string
  	add_column :nbas, :away_win_rank, :integer
  	add_column :nbas, :away_ppg_rank, :integer
  	add_column :nbas, :away_oppppg_rank, :integer
  end
end
