class AddDriveToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :first_drive, :integer
    add_column :games, :second_drive, :integer
  end
end
