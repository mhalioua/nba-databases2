class CreateCbbRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :cbb_records do |t|
      t.integer :cbb_player_id
      t.integer :cbb_game_id
      t.integer :team
      t.integer :order
      t.integer :min
      t.integer :score

      t.timestamps
    end
  end
end
