class FixColumns < ActiveRecord::Migration[5.1]
  def change
  	rename_column :teams, :order_thr_fore, :order_thr_five
  end
end
