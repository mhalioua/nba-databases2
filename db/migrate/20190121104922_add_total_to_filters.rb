class AddTotalToFilters < ActiveRecord::Migration[5.1]
  def change
    add_column :filters, :full_half_away, :integer
    add_column :filters, :full_half_home, :integer
    add_column :filters, :full_under, :integer
    add_column :filters, :full_over, :integer
  end
end
