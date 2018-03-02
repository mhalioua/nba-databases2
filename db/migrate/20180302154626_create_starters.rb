class CreateStarters < ActiveRecord::Migration[5.1]
  def change
    create_table :starters do |t|
      t.string	:time
      t.string	:team
      t.integer	:index
      t.string	:position
      t.string	:player_name
      
      t.timestamps
    end
  end
end
