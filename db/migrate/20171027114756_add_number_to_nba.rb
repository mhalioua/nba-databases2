class AddNumberToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :home_number, :integer
  	add_column :nbas, :away_number, :integer
  end
end
