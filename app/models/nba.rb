class Nba < ApplicationRecord
	has_many :players
	has_many :player_datas
	has_many :compares
	has_many :team_stats
	has_many :filters
	default_scope { where(is_deleted: false) }
end
