class IndexController < ApplicationController
	before_action :confirm_logged_in
	def home
		@yesterday = Time.now - 1.days
    	@today = Time.now
    	@tomorrow = Time.now + 1.days
  	end

	def game
	  	unless params[:id]
	  	  	params[:id] = Time.now.strftime("%Y%m%d")
	  	end
		@game_index = params[:id]

  		@head = Date.strptime(@game_index, '%Y%m%d').strftime("%B %e")
  		@prev = (Date.strptime(@game_index, '%Y%m%d') - 1.days).strftime("%Y%m%d")
  		@next = (Date.strptime(@game_index, '%Y%m%d') + 1.days).strftime("%Y%m%d")
		@games = Nba.where("game_date between ? and ?", Date.strptime(@game_index, '%Y%m%d').beginning_of_day, Date.strptime(@game_index, '%Y%m%d').end_of_day)
	  				.order("game_date")
	end

	def detail
		@game_id = params[:id]
		@game = Nba.find_by(game_id: @game_id)
		@head = @game.away_team + " @ " + @game.home_team
		
		@home_abbr = @game.home_abbr
		@away_abbr = @game.away_abbr

		@now = Date.strptime(@game.game_date)
		if @now > Time.now
			@now = Time.now
		end

		@away_last = Nba.where("home_abbr = ? AND game_date < ?", @away_abbr, @now).or(Nba.where("away_abbr = ? AND game_date < ?", @away_abbr, @now)).order(:game_date).last
		@home_last = Nba.where("home_abbr = ? AND game_date < ?", @home_abbr, @now).or(Nba.where("away_abbr = ? AND game_date < ?", @home_abbr, @now)).order(:game_date).last
		
		if @away_abbr == @away_last.away_abbr
			@away_flag = 0
		else
			@away_flag = 1
		end

		if @home_abbr == @home_last.away_abbr
			@home_flag = 0
		else
			@home_flag = 1
		end

		@date_id = Date.strptime(@game.game_date).strftime("%Y%m%d")

		@away_players = @away_last.players.where("team_abbr = ? AND mins > 5", @away_flag).order(:state)
		@away_players_group1 = @away_last.players.where("team_abbr = ? AND state < 6 AND position = 'PG' AND mins > 5", @away_flag).or(@away_last.players.where("team_abbr = ? AND state < 6 AND position = 'SG' AND mins > 5", @away_flag)).order(:state)
		@away_players_group2 = @away_last.players.where("team_abbr = ? AND state < 6 AND position = 'C' AND mins > 5", @away_flag).or(@away_last.players.where("team_abbr = ? AND state < 6 AND position = 'SF' AND mins > 5", @away_flag).or(@away_last.players.where("team_abbr = ? AND state < 6 AND position = 'PF' AND mins > 5", @away_flag))).order(:state)
		@away_players_group3 = @away_last.players.where("team_abbr = ? AND state > 5 AND mins > 5", @away_flag).order(:state)
		@away_players_group3 = @away_players_group3[0..-2]
		@away_players = @away_players[0..-2]

		@home_players = @home_last.players.where("team_abbr = ? AND mins > 5", @home_flag).order(:state)
		@home_players_group1 = @home_last.players.where("team_abbr = ? AND state < 6 AND position = 'PG' AND mins > 5", @home_flag).or(@home_last.players.where("team_abbr = ? AND state < 6 AND position = 'SG' AND mins > 5", @home_flag)).order(:state)
		@home_players_group2 = @home_last.players.where("team_abbr = ? AND state < 6 AND position = 'C' AND mins > 5", @home_flag).or(@home_last.players.where("team_abbr = ? AND state < 6 AND position = 'SF' AND mins > 5", @home_flag).or(@home_last.players.where("team_abbr = ? AND state < 6 AND position = 'PF' AND mins > 5", @home_flag))).order(:state)
		@home_players_group3 = @home_last.players.where("team_abbr = ? AND state > 5 AND mins > 5", @home_flag).order(:state)
		@home_players_group3 = @home_players_group3[0..-2]
		@home_players = @home_players[0..-2]

		@away_players_group1 = @away_players_group1.reject{|player|
			count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        player.sum_mins/(count - 2) < 5
		}

		@away_players_group2 = @away_players_group2.reject{|player|
			count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        player.sum_mins/(count - 2) < 5
		}

		@away_players_group3 = @away_players_group3.reject{|player|
			count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        player.sum_mins/(count - 2) < 5
		}

		@away_players = @away_players.reject{|player|
			count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        player.sum_mins/(count - 2) < 5
		}

		@home_players = @home_players.reject{|player|
			count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        player.sum_mins/(count - 2) < 5
		}

		@home_players_group1 = @home_players_group1.reject{|player|
			count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        player.sum_mins/(count - 2) < 5
		}

		@home_players_group2 = @home_players_group2.reject{|player|
			count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        player.sum_mins/(count - 2) < 5
		}

		@home_players_group3 = @home_players_group3.reject{|player|
			count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        player.sum_mins/(count - 2) < 5
		}

		@away_total_poss = 0
	    @away_total_min = 0
	    @away_drtg_one = 0
	    @away_players_group1.each_with_index do |player, index| 
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        @away_drtg_one = @away_drtg_one + player.drtg
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    @away_drtg_one = @away_drtg_one.to_f / @away_players_group1.size

	    @away_drtg_two = 0
	    @away_players_group2.each_with_index do |player, index|
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        @away_drtg_two = @away_drtg_two + player.drtg
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    @away_drtg_two = @away_drtg_two.to_f / @away_players_group2.size

	    @away_players_group3.each_with_index do |player, index|
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	    end

	    @home_total_poss = 0
	    @home_total_min = 0
	    @home_drtg_one = 0
	    @home_players_group1.each_with_index do |player, index| 
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        @home_drtg_one = @home_drtg_one + player.drtg
	    end
	    @home_drtg_one = @home_drtg_one.to_f / @home_players_group1.size

	    @home_drtg_two = 0
	    @home_players_group2.each_with_index do |player, index| 
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        @home_drtg_two = @home_drtg_two + player.drtg
	    end
	    @home_drtg_two = @home_drtg_two.to_f / @home_players_group2.size

	    @home_players_group3.each_with_index do |player, index|
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	    end 
	end
end
