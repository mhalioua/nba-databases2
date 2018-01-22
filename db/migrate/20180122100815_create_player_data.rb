class CreatePlayerData < ActiveRecord::Migration[5.1]
  def change
    create_table :player_data do |t|
        t.integer :nba_id
        t.integer :team_abbr
      	t.string :player_name
      	t.string :position
      	t.string :possession
      	t.float :ortg
      	t.float :drtg
      	t.integer :state
       	t.float :poss
       	t.float :sum_poss
       	t.float :team_poss
       	t.integer :mins
       	t.integer :fga
       	t.integer :fta
       	t.integer :toValue
       	t.integer :orValue
       	t.integer :sum_mins
       	t.float :prorate
       	t.string :height
       	t.string :link
       	t.string :game_date
       	t.string :player_link
       	t.string :player_fullname
       	t.integer :ptsValue
       	t.integer :sum_or
       	t.integer :sum_stl
       	t.integer :sum_blk
       	t.integer :stlValue
       	t.integer :blkValue

      	t.timestamps
    end
  end
end
