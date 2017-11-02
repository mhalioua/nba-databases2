class CreateTgs < ActiveRecord::Migration[5.1]
  def change
    create_table :tgs do |t|
      t.string :player_name
      t.string :team_abbr
      t.integer :year
      t.integer :ortg
      t.integer :drtg

      t.timestamps
    end
  end
end
