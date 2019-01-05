class CreateFilters < ActiveRecord::Migration[5.1]
  def change
    create_table :filters do |t|
      t.integer :nba_id
      t.integer :index
      t.string :first_one
      t.float :first
      t.float :second
      t.float :full
      t.integer :count
      t.float :allfirst
      t.float :allsecond
      t.float :allfull
      t.integer :allcount
      t.float :home_ortg
      t.float :away_ortg
      t.float :bj
      t.float :bg
      t.float :bh
      t.integer :first_under
      t.integer :first_over
      t.integer :second_under
      t.integer :second_over
      t.integer :first_half_away
      t.integer :first_half_home
      t.integer :second_half_away
      t.integer :second_half_home

      t.float :full_first
      t.float :full_second
      t.float :firsthalf_first
      t.float :firsthalf_second
      t.float :secondhalf_first
      t.float :secondhalf_second
      t.float :bi_one
      t.float :bi_two
      t.integer :bi_count

      t.timestamps
    end
  end
end
