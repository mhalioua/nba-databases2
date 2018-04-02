class AddTodayToInjury < ActiveRecord::Migration[5.1]
  def change
  	add_column :injuries, :today, :date
  end
end
