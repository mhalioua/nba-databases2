class AddPlayersToNba < ActiveRecord::Migration[5.1]
  def change
    add_column :nbas, :away_player1_name, :string
    add_column :nbas, :away_player1_birthday, :string
    add_column :nbas, :away_player2_name, :string
    add_column :nbas, :away_player2_birthday, :string
    add_column :nbas, :away_player3_name, :string
    add_column :nbas, :away_player3_birthday, :string
    add_column :nbas, :away_player4_name, :string
    add_column :nbas, :away_player4_birthday, :string
    add_column :nbas, :away_player5_name, :string
    add_column :nbas, :away_player5_birthday, :string
    add_column :nbas, :away_player6_name, :string
    add_column :nbas, :away_player6_birthday, :string
    add_column :nbas, :away_player7_name, :string
    add_column :nbas, :away_player7_birthday, :string
    add_column :nbas, :away_player8_name, :string
    add_column :nbas, :away_player8_birthday, :string

    add_column :nbas, :home_player1_name, :string
    add_column :nbas, :home_player1_birthday, :string
    add_column :nbas, :home_player2_name, :string
    add_column :nbas, :home_player2_birthday, :string
    add_column :nbas, :home_player3_name, :string
    add_column :nbas, :home_player3_birthday, :string
    add_column :nbas, :home_player4_name, :string
    add_column :nbas, :home_player4_birthday, :string
    add_column :nbas, :home_player5_name, :string
    add_column :nbas, :home_player5_birthday, :string
    add_column :nbas, :home_player6_name, :string
    add_column :nbas, :home_player6_birthday, :string
    add_column :nbas, :home_player7_name, :string
    add_column :nbas, :home_player7_birthday, :string
    add_column :nbas, :home_player8_name, :string
    add_column :nbas, :home_player8_birthday, :string
  end
end
