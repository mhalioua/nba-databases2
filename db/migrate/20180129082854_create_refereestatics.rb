class CreateRefereestatics < ActiveRecord::Migration[5.1]
  def change
    create_table :refereestatics do |t|
		t.string :referee_one
		t.string :referee_two
		t.string :referee_three
		t.integer :last_count
		t.float :last_first
		t.float :last_second
		t.integer :next_count
		t.float :next_first
		t.float :next_second
      t.timestamps
    end
  end
end
