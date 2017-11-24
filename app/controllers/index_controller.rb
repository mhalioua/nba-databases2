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

		@away_players = @away_last.players.where("team_abbr = ?", @away_flag).order(:state)
		@away_players_group1 = @away_last.players.where("team_abbr = ? AND state < 6 AND position = 'PG'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state < 6 AND position = 'SG'", @away_flag)).order(:state)
		@away_players_group2 = @away_last.players.where("team_abbr = ? AND state < 6 AND position = 'C'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state < 6 AND position = 'SF'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state < 6 AND position = 'PF'", @away_flag))).order(:state)
		@away_players_group3 = @away_last.players.where("team_abbr = ? AND state > 5", @away_flag).order(:state)
		@away_players_group3 = @away_players_group3[0..-2]
		@away_players = @away_players[0..-2]

		@home_players = @home_last.players.where("team_abbr = ?", @home_flag).order(:state)
		@home_players_group1 = @home_last.players.where("team_abbr = ? AND state < 6 AND position = 'PG'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state < 6 AND position = 'SG'", @home_flag)).order(:state)
		@home_players_group2 = @home_last.players.where("team_abbr = ? AND state < 6 AND position = 'C'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state < 6 AND position = 'SF'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state < 6 AND position = 'PF'", @home_flag))).order(:state)
		@home_players_group3 = @home_last.players.where("team_abbr = ? AND state > 5", @home_flag).order(:state)
		@home_players_group3 = @home_players_group3[0..-2]
		@home_players = @home_players[0..-2]

		
		@away_total_poss = 0
	    @away_total_min = 0
	    @away_drtg_one = 0
	    remove_count = 0
	    @away_players_group1.each_with_index do |player, index| 
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        if count == 2
	        	count = 1
	        end
	        if player.sum_mins/(count - 2) < 10 || count < 10
	        	remove_count = remove_count + 1
	        	next
	        end
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        @away_drtg_one = @away_drtg_one + player.drtg
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    @away_drtg_one = @away_drtg_one.to_f / (@away_players_group1.size - remove_count)

	    @away_drtg_two = 0
	    remove_count = 0
	    @away_players_group2.each_with_index do |player, index|
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        if count == 2
	        	count = 1
	        end
	        if player.sum_mins/(count - 2) < 10 || count < 10
	        	remove_count = remove_count + 1
	        	next
	        end
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        @away_drtg_two = @away_drtg_two + player.drtg
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    @away_drtg_two = @away_drtg_two.to_f / (@away_players_group2.size - remove_count)

	    @away_players_group3.each_with_index do |player, index|
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        if count == 2
	        	count = 1
	        end
	        if player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    @home_total_poss = 0
	    @home_total_min = 0
	    @home_drtg_one = 0
	    remove_count = 0
	    @home_players_group1.each_with_index do |player, index| 
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        if count == 2
	        	count = 1
	        end
	        if player.sum_mins/(count - 2) < 10 || count < 10
	        	remove_count = remove_count + 1
	        	next
	        end
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        @home_drtg_one = @home_drtg_one + player.drtg
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    @home_drtg_one = @home_drtg_one.to_f / (@home_players_group1.size - remove_count)

	    @home_drtg_two = 0
	    remove_count = 0
	    @home_players_group2.each_with_index do |player, index| 
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        if count == 2
	        	count = 1
	        end
	        if player.sum_mins/(count - 2) < 10 || count < 10
	        	remove_count = remove_count + 1
	        	next
	        end
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        @home_drtg_two = @home_drtg_two + player.drtg
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    @home_drtg_two = @home_drtg_two.to_f / ( @home_players_group2.size - remove_count )

	    @home_players_group3.each_with_index do |player, index|
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count + 1
	        end
	        if count == 2
	        	count = 1
	        end
	        if player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    
   	    @home_team_info = Team.find_by(abbr: @home_abbr)
	    @away_team_info = Team.find_by(abbr: @away_abbr)
	    @filters = [
			[true, false, false, true, true, true],
			[false, true, true, false, true, true],
			[true, true, false, false, true, true],
			[false, false, true, true, true, true],

			[true, false, false, true, true, false],
			[false, true, true, false, true, false],
			[true, true, false, false, true, false],
			[false, false, true, true, true, false],

			[true, false, false, true, false, true],
			[false, true, true, false, false, true],
			[true, true, false, false, false, true],
			[false, false, true, true, false, true],

			[false, false, true, false, true, true],
			[false, true, false, false, true, true],

			[false, true, true, true, true, true],
			[true, false, true, true, true, true],
			[true, true, false, true, true, true],
			[true, true, true, false, true, true],

			[false, true, true, true, true, false],
			[true, false, true, true, true, false],
			[true, true, false, true, true, false],
			[true, true, true, false, true, false],

			[false, true, true, true, false, true],
			[true, false, true, true, false, true],
			[true, true, false, true, false, true],
			[true, true, true, false, false, true],

			[false, true, true, false, false, false],

			[true, true, true, true, true, true],

			[true, true, true, true, false, false]
		]
		@break = [3, 7, 11, 13, 17, 21, 25, 26, 27]
		@filterResult = []
		@filters.each do |filter|
			search_string = []
			if filter[0]
				search_string.push("away_last_game = '#{@game.away_last_game}'")
				filter[0] = @game.away_last_game
			end
			if filter[1]
				search_string.push("away_next_game = '#{@game.away_next_game}'")
				filter[1] = @game.away_next_game
			end
			if filter[2]
				search_string.push("home_next_game = '#{@game.home_next_game}'")
				filter[2] = @game.home_next_game
			end
			if filter[3]
				search_string.push("home_last_game = '#{@game.home_last_game}'")
				filter[3] = @game.home_last_game
			end
			if filter[4]
				search_string.push("home_next_fly = '#{@game.home_next_fly}'")
				filter[4] = @game.home_next_fly[0]
			end
			if filter[5]
				search_string.push("home_last_fly = '#{@game.home_last_fly}'")
				filter[6] = @game.home_last_fly[0]
			end
			search_string = search_string.join(" AND ")
			filter_element = Nba.where(search_string)
			result_element = {
				first: filter_element.average(:first_point),
				second: filter_element.average(:second_point),
				full: filter_element.average(:total_point),
				count: filter_element.count(:total_point)
			}
			@filterResult.push(result_element)
		end
	end

	def history
		unless params[:id]
	  	  	params[:id] = (Time.now - 10.days).strftime("%Y-%m-%d") + " - " + (Time.now - 1.days).strftime("%Y-%m-%d")
	  	end
	  	@game_index = params[:id]
	  	@game_start_index = @game_index[0..9]
	  	@game_end_index = @game_index[13..23]
	  	@game_date = []
	  	date = Date.strptime(@game_start_index)
	  	while date <= Date.strptime(@game_end_index)
	  		@game_date << date
	  		date = date + 1.days
	  	end
  	end
end
