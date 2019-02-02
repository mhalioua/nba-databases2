class AddGameDateToCbbRecord < ActiveRecord::Migration[5.1]
  def change
    add_column :cbb_records, :game_date, :string
  end
end
