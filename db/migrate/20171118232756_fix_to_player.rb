class FixToPlayer < ActiveRecord::Migration[5.1]
  def change
  	remove_column :nbas, :first_line
  	remove_column :nbas, :second_line
  	remove_column :nbas, :full_line

  	remove_column :nbas, :first_side
  	remove_column :nbas, :second_side
  	remove_column :nbas, :full_side

  	add_column :nbas, :first_opener_side, :float
  	add_column :nbas, :first_closer_side, :float 
  	add_column :nbas, :first_opener_total, :float 
  	add_column :nbas, :first_closer_total, :float
  	add_column :nbas, :second_opener_side, :float
  	add_column :nbas, :second_closer_side, :float 
  	add_column :nbas, :second_opener_total, :float 
  	add_column :nbas, :second_closer_total, :float
  	add_column :nbas, :full_opener_side, :float
  	add_column :nbas, :full_closer_side, :float 
  	add_column :nbas, :full_opener_total, :float 
  	add_column :nbas, :full_closer_total, :float
  end
end
