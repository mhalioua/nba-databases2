class CreateCounts < ActiveRecord::Migration[5.1]
  def change
    create_table :counts do |t|
      t.string :lastroad
      t.string :nextroad
      t.string :nexthome
      t.string :lasthome
      t.float :road
      t.float :home
      t.float :diff
      t.integer :count
      t.float :firstroad
      t.float :firsthome
      t.float :firstdiff
      t.float :secondroad
      t.float :secondhome
      t.float :seconddiff

      t.timestamps
    end
  end
end
