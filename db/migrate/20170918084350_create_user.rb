class CreateUser < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
    	t.string :username, :default => ""
    	t.string :password_digest, :default => ""
      	t.timestamps
    end
  end
end
