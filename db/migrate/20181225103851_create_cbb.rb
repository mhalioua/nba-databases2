class CreateCbb < ActiveRecord::Migration[5.1]
  def change
    create_table :cbbs do |t|
      t.string :player
      t.string :birthdate
      t.string :team_name
    end
  end
end
