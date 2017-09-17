class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.string :home_team
      t.string :away_team
      t.string :result

      t.timestamps
    end
  end
end
