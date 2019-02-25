class AddColumnsToFullseason < ActiveRecord::Migration[5.1]
  def change
  	add_column :fullseasons, :awaylastfly, :string
		add_column :fullseasons, :awaynextfly, :string
		add_column :fullseasons, :away_win_rank, :integer
		add_column :fullseasons, :away_ppg_rank, :integer
		add_column :fullseasons, :away_oppppg_rank, :integer
		add_column :fullseasons, :home_win_rank, :integer
		add_column :fullseasons, :home_ppg_rank, :integer
		add_column :fullseasons, :home_oppppg_rank, :integer
		add_column :fullseasons, :firstou, :string
		add_column :fullseasons, :secondou, :string
		add_column :fullseasons, :totalou, :string
		add_column :fullseasons, :hometeamlastgame, :string
		add_column :fullseasons, :roadteamlastgame, :string
		add_column :fullseasons, :pace, :float
		add_column :fullseasons, :away_ortg, :float
		add_column :fullseasons, :home_ortg, :float
		add_column :fullseasons, :away_last_home, :integer
		add_column :fullseasons, :away_next_home, :integer
  end
end
