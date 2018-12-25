class CreateCbbs < ActiveRecord::Migration[5.1]
  def change
    create_table :cbbs do |t|
      t.string :player
      t.string :birthdate
      t.string :team_name
      t.timestamps
    end
  end
end
