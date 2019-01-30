class RenameClassToPlayerClassCbbPlayers < ActiveRecord::Migration[5.1]
  def change
    rename_column :cbb_players, :class, :player_class
  end
end
