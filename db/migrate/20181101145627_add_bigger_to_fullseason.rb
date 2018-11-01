class AddBiggerToFullseason < ActiveRecord::Migration[5.1]
  def change
    add_column :fullseasons, :first_half_bigger, :string
    add_column :fullseasons, :second_half_bigger, :string
    add_column :fullseasons, :fullgame_bigger, :string
  end
end
