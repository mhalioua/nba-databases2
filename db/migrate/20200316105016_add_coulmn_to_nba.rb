class AddCoulmnToNba < ActiveRecord::Migration[5.1]
  def change
  	add_column :nbas, :is_deleted, :boolean, default: false
  end
end
