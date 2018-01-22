class Nba < ApplicationRecord
	has_many :players
	has_many :player_datas
	has_many :compares
end
