class CreateFullseasons < ActiveRecord::Migration[5.1]
  def change
    create_table :fullseasons do |t|
      t.integer :year
      t.string :date
      t.string :time
      t.string :week
      t.integer :roadlast
      t.integer :roadnext
      t.string :roadteam
      t.string :roadmore
      t.integer :roadfirst
      t.integer :roadsecond
      t.integer :roadfirsthalf
      t.integer :roadthird
      t.integer :roadforth
      t.integer :roadot
      t.integer :homenext
      t.string :homenextfly
      t.integer :homelast
      t.string :homelastfly
      t.string :hometeam
      t.string :homemore
      t.integer :homefirst
      t.integer :homesecond
      t.integer :homefirsthalf
      t.integer :homethird
      t.integer :homeforth
      t.integer :homeot
      t.integer :homediff
      t.integer :roadtotal
      t.integer :hometotal
      t.integer :total
      t.integer :firstpoint
      t.integer :secondpoint
      t.integer :totalpoint
      t.float :firstlinetotal
      t.float :secondlinetotal
      t.float :fglinetotal
      t.float :firstside
      t.float :secondside
      t.float :fgside

      t.timestamps
    end
  end
end
