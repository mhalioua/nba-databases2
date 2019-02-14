class AddGameColumnsToNba < ActiveRecord::Migration[5.1]
  def change
    add_column :nbas, :home_last_home, :integer
    add_column :nbas, :home_next_home, :integer
  end
end
