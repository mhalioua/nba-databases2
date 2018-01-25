class AddRefereeToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :referee_one, :string
  	add_column :nbas, :referee_one_last, :integer
  	add_column :nbas, :referee_one_next, :integer
  	add_column :nbas, :referee_two, :string
  	add_column :nbas, :referee_two_last, :integer
  	add_column :nbas, :referee_two_next, :integer
  	add_column :nbas, :referee_three, :string
  	add_column :nbas, :referee_three_last, :integer
  	add_column :nbas, :referee_three_next, :integer
  end
end
