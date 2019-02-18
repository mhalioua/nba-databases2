class AddHomeLastAwayToNba < ActiveRecord::Migration[5.1]
  def change
    add_column :nbas, :home_last_away, :integer
    add_column :nbas, :home_next_away, :integer
  end
end
