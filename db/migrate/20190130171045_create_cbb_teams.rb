class CreateCbbTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :cbb_teams do |t|
      t.string :name
      t.string :abbr
      t.string :link

      t.timestamps
    end
  end
end
