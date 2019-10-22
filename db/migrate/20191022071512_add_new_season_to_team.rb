class AddNewSeasonToTeam < ActiveRecord::Migration[5.1]
  def change
    rename_column :teams, :order_one_seventeen, :order_one_nineteen
    rename_column :teams, :order_two_seventeen, :order_two_nineteen
    rename_column :teams, :order_thr_seventeen, :order_thr_nineteen

    add_column :teams, :order_one_eighteen, :integer
    add_column :teams, :order_two_eighteen, :integer
    add_column :teams, :order_thr_eighteen, :integer

    add_column :teams, :order_one_seventeen, :integer
    add_column :teams, :order_two_seventeen, :integer
    add_column :teams, :order_thr_seventeen, :integer
  end
end
