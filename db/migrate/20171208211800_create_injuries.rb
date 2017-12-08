class CreateInjuries < ActiveRecord::Migration[5.1]
  def change
    create_table :injuries do |t|
    	t.string :team
      	t.string :link
      	t.integer :date
      	t.string :name
      	t.string :status
      	t.string :text
      t.timestamps
    end
  end
end
