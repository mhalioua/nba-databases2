class AddTimeToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :time, :string
  	add_column :nbas, :week, :string
  end
end
