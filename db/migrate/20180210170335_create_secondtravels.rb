class CreateSecondtravels < ActiveRecord::Migration[5.1]
  def change
    create_table :secondtravels do |t|
      t.integer :year
      t.string :date
      t.string :time
      t.string :week
      t.integer :roadlast
      t.integer :roadnext
      t.string :roadteam
      t.integer :roadfirst
      t.integer :roadsecond
      t.integer :roadfirsthalf
      t.integer :roadthird
      t.integer :roadforth
      t.integer :roadot
      t.integer :roadsecondhalf
      t.integer :homenext
      t.string :homenextfly
      t.integer :homelast
      t.string :homelastfly
      t.string :hometeam
      t.integer :roadtotal
      t.integer :hometotal
      t.integer :homefirst
      t.integer :homesecond
      t.integer :homefirsthalf
      t.integer :homethird
      t.integer :homeforth
      t.integer :homeot
      t.integer :homesecondhalf
      t.integer :firstpoint
      t.integer :secondpoint
      t.integer :totalpoint
      t.float :fglinetotal
      t.float :fgside
      t.float :firstvalue
      t.float :secondvalue
      t.float :totalvalue
      t.string :awaylastfly
      t.string :awaynextfly
      t.timestamps
    end
  end
end
