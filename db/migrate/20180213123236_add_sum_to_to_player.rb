class AddSumToToPlayer < ActiveRecord::Migration[5.1]
  def change
  	add_column :players, :sum_to, :integer
  end
end
