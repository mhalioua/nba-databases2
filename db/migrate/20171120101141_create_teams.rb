class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
		t.string :team
		t.string :abbr
		t.float :current
		t.float :last_three
		t.float :last_one
		t.float :home
		t.float :away
		t.float :last
      	t.timestamps
    end
  end
end
