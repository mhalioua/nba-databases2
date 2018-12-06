class AddCountToNba < ActiveRecord::Migration[5.1]
  def change
    add_column :nbas, :fg_road_2000, :float
    add_column :nbas, :fg_home_2000, :float
    add_column :nbas, :fg_diff_2000, :float
    add_column :nbas, :fg_count_2000, :integer

    add_column :nbas, :fg_road_1990, :float
    add_column :nbas, :fg_home_1990, :float
    add_column :nbas, :fg_diff_1990, :float
    add_column :nbas, :fg_count_1990, :integer

    add_column :nbas, :first_half_road_2000, :float
    add_column :nbas, :first_half_home_2000, :float
    add_column :nbas, :first_half_diff_2000, :float
    add_column :nbas, :first_half_count_2000, :integer

    add_column :nbas, :first_half_road_1990, :float
    add_column :nbas, :first_half_home_1990, :float
    add_column :nbas, :first_half_diff_1990, :float
    add_column :nbas, :first_half_count_1990, :integer

    add_column :nbas, :second_half_road_2000, :float
    add_column :nbas, :second_half_home_2000, :float
    add_column :nbas, :second_half_diff_2000, :float
    add_column :nbas, :second_half_count_2000, :integer

    add_column :nbas, :second_half_road_1990, :float
    add_column :nbas, :second_half_home_1990, :float
    add_column :nbas, :second_half_diff_1990, :float
    add_column :nbas, :second_half_count_1990, :integer

    add_column :nbas, :fg_total_pt_2000, :float
    add_column :nbas, :fg_total_line_2000, :float
    add_column :nbas, :fg_total_diff_2000, :float
    add_column :nbas, :first_half_total_pt_2000, :float
    add_column :nbas, :first_half_total_line_2000, :float
    add_column :nbas, :first_half_total_diff_2000, :float
    add_column :nbas, :second_half_total_pt_2000, :float
    add_column :nbas, :second_half_total_line_2000, :float
    add_column :nbas, :second_half_total_diff_2000, :float

    add_column :nbas, :fg_total_pt_1990, :float
    add_column :nbas, :fg_total_line_1990, :float
    add_column :nbas, :fg_total_diff_1990, :float
    add_column :nbas, :first_half_total_pt_1990, :float
    add_column :nbas, :first_half_total_line_1990, :float
    add_column :nbas, :first_half_total_diff_1990, :float
    add_column :nbas, :second_half_total_pt_1990, :float
    add_column :nbas, :second_half_total_line_1990, :float
    add_column :nbas, :second_half_total_diff_1990, :float

    add_column :nbas, :fg_total_count_2000, :integer
    add_column :nbas, :first_half_total_count_2000, :integer
    add_column :nbas, :second_half_total_count_2000, :integer
    add_column :nbas, :fg_total_count_1990, :integer
    add_column :nbas, :first_half_total_count_1990, :integer
    add_column :nbas, :second_half_total_count_1990, :integer

    add_column :nbas, :first_half_bigger, :string
    add_column :nbas, :second_half_bigger, :string
    add_column :nbas, :fullgame_bigger, :string
  end
end
