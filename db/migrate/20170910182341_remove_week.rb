class RemoveWeek < ActiveRecord::Migration[5.1]
  def change
  	remove_column :games, :week_index, :string
  end
end
