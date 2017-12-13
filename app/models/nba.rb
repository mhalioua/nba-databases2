class Nba < ApplicationRecord
	has_many :players
	has_many :compares
end
