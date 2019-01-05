class AddYearToFilter < ActiveRecord::Migration[5.1]
  def change
    add_column :filters, :year, :integer
  end
end
