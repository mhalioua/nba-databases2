class AddMoreColumnsToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :year, :string
  	add_column :nbas, :date, :string
  end
end
