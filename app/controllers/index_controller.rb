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
	    drtg_count = 0
	    drtg_min = 0
	    @away_players_group1.each_with_index do |player, index| 
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
	        drtg_count = drtg_count + 1
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @away_drtg_one = @away_drtg_one + player.drtg * player.sum_mins/(count - 2)
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    if drtg_count < 3
	    	@away_players_group4 = @away_last.players.where("team_abbr = ? AND state > 5 AND position = 'PG'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state > 5 AND position = 'SG'", @away_flag)).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	@away_players_group4.each_with_index do |player, index| 
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
		        compare = player.sum_mins/(count - 2)
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	one_value = player.drtg
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	two_value = player.drtg
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = player.drtg
		        end
		    end
		    if drtg_count < 3
			    drtg_min = drtg_min + max_one
			    @away_drtg_one = @away_drtg_one + one_value * max_one
			end
			if drtg_count < 2
			    drtg_min = drtg_min + max_two
			    @away_drtg_one = @away_drtg_one + two_value * max_two
			end
			if drtg_count < 1
			    drtg_min = drtg_min + max_thr
			    @away_drtg_one = @away_drtg_one + thr_value * max_thr
			end
	    	@away_drtg_one = @away_drtg_one.to_f / drtg_min
	    end

	    @away_drtg_two = 0
	    drtg_count = 0
	    drtg_min = 0
	    @away_players_group2.each_with_index do |player, index|
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
	        drtg_count = drtg_count + 1
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @away_drtg_two = @away_drtg_two + player.drtg * player.sum_mins/(count - 2)
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    if drtg_count < 3
	    	@away_players_group4 = @away_last.players.where("team_abbr = ? AND state > 5 AND position = 'C'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state > 5 AND position = 'SF'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state > 5 AND position = 'PF'", @away_flag))).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	@away_players_group4.each_with_index do |player, index| 
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
		        compare = player.sum_mins/(count - 2)
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	one_value = player.drtg
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	two_value = player.drtg
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = player.drtg
		        end
		    end
		    if drtg_count < 3
			    drtg_min = drtg_min + max_one
			    @away_drtg_two = @away_drtg_two + one_value * max_one
			end
			if drtg_count < 2
			    drtg_min = drtg_min + max_two
			    @away_drtg_two = @away_drtg_two + two_value * max_two
			end
			if drtg_count < 1
			    drtg_min = drtg_min + max_thr
			    @away_drtg_two = @away_drtg_two + thr_value * max_thr
			end
	    	@away_drtg_two = @away_drtg_two.to_f / drtg_min
	    end

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
	    drtg_count = 0
	    drtg_min = 0
	    @home_players_group1.each_with_index do |player, index| 
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
	        drtg_count = drtg_count + 1
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @home_drtg_one = @home_drtg_one + player.drtg * player.sum_mins/(count - 2)
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    if drtg_count < 3
	    	@home_players_group4 = @home_last.players.where("team_abbr = ? AND state > 5 AND position = 'PG'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'SG'", @home_flag)).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	@home_players_group4.each_with_index do |player, index| 
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
		        compare = player.sum_mins/(count - 2)
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	one_value = player.drtg
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	two_value = player.drtg
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = player.drtg
		        end
		    end
		    if drtg_count < 3
			    drtg_min = drtg_min + max_one
			    @home_drtg_one = @home_drtg_one + one_value * max_one
			end
			if drtg_count < 2
			    drtg_min = drtg_min + max_two
			    @home_drtg_one = @home_drtg_one + two_value * max_two
			end
			if drtg_count < 1
			    drtg_min = drtg_min + max_thr
			    @home_drtg_one = @home_drtg_one + thr_value * max_thr
			end
	    	@home_drtg_one = @home_drtg_one.to_f / drtg_min
	    end

	    @home_drtg_two = 0
	    drtg_count = 0
	    drtg_min = 0
	    @home_players_group2.each_with_index do |player, index| 
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
	        drtg_count = drtg_count + 1
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @home_drtg_two = @home_drtg_two + player.drtg * player.sum_mins/(count - 2)
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    if drtg_count < 3
	    	@home_players_group4 = @home_last.players.where("team_abbr = ? AND state > 5 AND position = 'C'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'SF'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'PF'", @home_flag))).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	@home_players_group4.each_with_index do |player, index| 
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
		        compare = player.sum_mins/(count - 2)
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	one_value = player.drtg
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	two_value = player.drtg
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = player.drtg
		        end
		    end
		    if drtg_count < 3
			    drtg_min = drtg_min + max_one
			    @home_drtg_two = @home_drtg_two + one_value * max_one
			end
			if drtg_count < 2
			    drtg_min = drtg_min + max_two
			    @home_drtg_two = @home_drtg_two + two_value * max_two
			end
			if drtg_count < 1
			    drtg_min = drtg_min + max_thr
			    @home_drtg_two = @home_drtg_two + thr_value * max_thr
			end
	    	@home_drtg_two = @home_drtg_two.to_f / drtg_min
	    end

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
		@break = [3, 7, 11, 13, 17, 21, 25, 26, 27, 28]
		@filterResult = []
		@filters.each do |filter|
			search_string = []
			if filter[0]
				search_string.push("roadlast = '#{@game.away_last_game}'")
				filter[0] = @game.away_last_game
			end
			if filter[1]
				search_string.push("roadnext = '#{@game.away_next_game}'")
				filter[1] = @game.away_next_game
			end
			if filter[2]
				search_string.push("homenext = '#{@game.home_next_game}'")
				filter[2] = @game.home_next_game
			end
			if filter[3]
				search_string.push("homelast = '#{@game.home_last_game}'")
				filter[3] = @game.home_last_game
			end
			if filter[4]
				search_string.push("homenextfly = '#{@game.home_next_fly}'")
				filter[4] = @game.home_next_fly[0]
			end
			if filter[5]
				search_string.push("homelastfly = '#{@game.home_last_fly}'")
				filter[5] = @game.home_last_fly[0]
			end
			search_string = search_string.join(" AND ")
			filter_element = Fullseason.where(search_string)
			result_element = {
				first: filter_element.average(:firstpoint).to_f.round(2),
				second: filter_element.average(:secondpoint).to_f.round(2),
				full: filter_element.average(:totalpoint).to_f.round(2),
				count: filter_element.count(:totalpoint).to_i
			}
			@home_team_info = Team.find_by(abbr: @home_abbr)
	    	@away_team_info = Team.find_by(abbr: @away_abbr)
			@filterResult.push(result_element)
		end
		@team_more = {
			'Atlanta' => 'EAST',
			'Boston' => 'EAST',
			'Brooklyn' => 'EAST',
			'Charlotte' => 'EAST',
			'Chicago' => 'MID-WEST',
			'Cleveland' => 'EAST',
			'Dallas' => 'TEXANS',
			'Denver' => 'ROCKIES',
			'Detroit' => 'EAST',
			'Golden State' => 'WEST COAST',
			'Houston' => 'TEXANS',
			'Indiana' => 'EAST',
			'LAC' => 'WEST COAST',
			'LAL' => 'WEST COAST',
			'Memphis' => 'NULL',
			'Miami' => 'EAST',
			'Milwaukee' => 'MID-WEST',
			'Minnesota' => 'MID-WEST',
			'New Jersey' => 'EAST',
			'New Orleans' => 'NULL',
			'New York' => 'EAST',
			'NO/Oklahoma City' => 'NULL',
			'Oklahoma City' => 'NULL',
			'Orlando' => 'EAST',
			'Philadelphia' => 'EAST',
			'Phoenix' => 'NULL',
			'Portland' => 'WEST COAST',
			'Sacramento' => 'WEST COAST',
			'San Antonio' => 'TEXANS',
			'Seattle' => 'NULL',
			'Toronto' => 'EAST',
			'Utah' => 'ROCKIES',
			'Vancouver' => 'NULL',
			'Washington' => 'EAST'
		}

		firstItem = Fullseason.where(homemore: @team_more[@game.home_team] ? @team_more[@game.home_team] : "NULL", roadmore: @team_more[@game.away_team] ? @team_more[@game.away_team] : "NULL" )
		secondItem = Fullseason.where(hometeam: @game.home_team)
		thirdItem = Fullseason.where(week: @game.week)
		forthItem = Fullseason.where("homenextfly = '#{@game.home_next_fly}' AND homelastfly = '#{@game.home_last_fly}'")
		@firstItem_result = {
			first: firstItem.average(:firstpoint).to_f.round(2),
			second: firstItem.average(:secondpoint).to_f.round(2),
			full: firstItem.average(:totalpoint).to_f.round(2),
			count: firstItem.count(:totalpoint).to_i
		}
		@secondItem_result = {
			first: secondItem.average(:firstpoint).to_f.round(2),
			second: secondItem.average(:secondpoint).to_f.round(2),
			full: secondItem.average(:totalpoint).to_f.round(2),
			count: secondItem.count(:totalpoint).to_i
		}
		@thirdItem_result = {
			first: thirdItem.average(:firstpoint).to_f.round(2),
			second: thirdItem.average(:secondpoint).to_f.round(2),
			full: thirdItem.average(:totalpoint).to_f.round(2),
			count: thirdItem.count(:totalpoint).to_i
		}
		@forthItem_result = {
			first: forthItem.average(:firstpoint).to_f.round(2),
			second: forthItem.average(:secondpoint).to_f.round(2),
			full: forthItem.average(:totalpoint).to_f.round(2),
			count: forthItem.count(:totalpoint).to_i
		}
		if @game.home_first_quarter && @game.home_second_quarter && @game.away_first_quarter && @game.away_second_quarter
			@diff = @game.home_first_quarter + @game.home_second_quarter - @game.away_first_quarter - @game.away_second_quarter
		else
			@diff = 0
		end
		lastfirstItem = Fullseason.where(homediff: @diff-5..@diff+5)
		lastsecondItem = Fullseason.where("homefirsthalf > 60")
		lastthirdItem = Fullseason.where("roadfirsthalf > 60")
		@lastfirstItem_result = {
			first: lastfirstItem.average(:firstpoint).to_f.round(2),
			second: lastfirstItem.average(:secondpoint).to_f.round(2),
			full: lastfirstItem.average(:totalpoint).to_f.round(2),
			count: lastfirstItem.count(:totalpoint).to_i
		}
		@lastsecondItem_result = {
			first: lastsecondItem.average(:firstpoint).to_f.round(2),
			second: lastsecondItem.average(:secondpoint).to_f.round(2),
			full: lastsecondItem.average(:totalpoint).to_f.round(2),
			count: lastsecondItem.count(:totalpoint).to_i
		}
		@lastthirdItem_result = {
			first: lastthirdItem.average(:firstpoint).to_f.round(2),
			second: lastthirdItem.average(:secondpoint).to_f.round(2),
			full: lastthirdItem.average(:totalpoint).to_f.round(2),
			count: lastthirdItem.count(:totalpoint).to_i
		}

		@countItem = Count.where("lastroad like ? AND nextroad like ? AND nexthome like ? AND lasthome like ?", "%#{@game.away_last_game}%", "%#{@game.away_next_game}%", "%#{@game.home_next_game}%", "%#{@game.home_last_game}%").first
	end

	def rest
		@game_id = params[:id]
		@game = Nba.find_by(game_id: @game_id)
		@head = @game.away_team + " @ " + @game.home_team
		
		@home_abbr = @game.home_abbr
		@away_abbr = @game.away_abbr

		@now = Date.strptime(@game.game_date)
		if @now > Time.now
			@now = Time.now
		end

		@date_id = Date.strptime(@game.game_date).strftime("%Y%m%d")	    

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
		@break = [3, 7, 11, 13, 17, 21, 25, 26, 27, 28]
		@filterResult = []
		@filters.each do |filter|
			search_string = []
			if filter[0]
				search_string.push("roadlast = '#{@game.away_last_game}'")
				filter[0] = @game.away_last_game
			end
			if filter[1]
				search_string.push("roadnext = '#{@game.away_next_game}'")
				filter[1] = @game.away_next_game
			end
			if filter[2]
				search_string.push("homenext = '#{@game.home_next_game}'")
				filter[2] = @game.home_next_game
			end
			if filter[3]
				search_string.push("homelast = '#{@game.home_last_game}'")
				filter[3] = @game.home_last_game
			end
			if filter[4]
				search_string.push("homenextfly = '#{@game.home_next_fly}'")
				filter[4] = @game.home_next_fly[0]
			end
			if filter[5]
				search_string.push("homelastfly = '#{@game.home_last_fly}'")
				filter[5] = @game.home_last_fly[0]
			end
			search_string = search_string.join(" AND ")
			filter_element = Fullseason.where(search_string)
			result_element = {
				first: filter_element.average(:firstpoint).to_f.round(2),
				second: filter_element.average(:secondpoint).to_f.round(2),
				full: filter_element.average(:totalpoint).to_f.round(2),
				count: filter_element.count(:totalpoint).to_i
			}
			@home_team_info = Team.find_by(abbr: @home_abbr)
	    	@away_team_info = Team.find_by(abbr: @away_abbr)
			@filterResult.push(result_element)
		end
		@team_more = {
			'Atlanta' => 'EAST',
			'Boston' => 'EAST',
			'Brooklyn' => 'EAST',
			'Charlotte' => 'EAST',
			'Chicago' => 'MID-WEST',
			'Cleveland' => 'EAST',
			'Dallas' => 'TEXANS',
			'Denver' => 'ROCKIES',
			'Detroit' => 'EAST',
			'Golden State' => 'WEST COAST',
			'Houston' => 'TEXANS',
			'Indiana' => 'EAST',
			'LAC' => 'WEST COAST',
			'LAL' => 'WEST COAST',
			'Memphis' => 'NULL',
			'Miami' => 'EAST',
			'Milwaukee' => 'MID-WEST',
			'Minnesota' => 'MID-WEST',
			'New Jersey' => 'EAST',
			'New Orleans' => 'NULL',
			'New York' => 'EAST',
			'NO/Oklahoma City' => 'NULL',
			'Oklahoma City' => 'NULL',
			'Orlando' => 'EAST',
			'Philadelphia' => 'EAST',
			'Phoenix' => 'NULL',
			'Portland' => 'WEST COAST',
			'Sacramento' => 'WEST COAST',
			'San Antonio' => 'TEXANS',
			'Seattle' => 'NULL',
			'Toronto' => 'EAST',
			'Utah' => 'ROCKIES',
			'Vancouver' => 'NULL',
			'Washington' => 'EAST'
		}

		firstItem = Fullseason.where(homemore: @team_more[@game.home_team] ? @team_more[@game.home_team] : "NULL", roadmore: @team_more[@game.away_team] ? @team_more[@game.away_team] : "NULL" )
		secondItem = Fullseason.where(hometeam: @game.home_team)
		thirdItem = Fullseason.where(week: @game.week)
		forthItem = Fullseason.where("homenextfly = '#{@game.home_next_fly}' AND homelastfly = '#{@game.home_last_fly}'")
		@firstItem_result = {
			first: firstItem.average(:firstpoint).to_f.round(2),
			second: firstItem.average(:secondpoint).to_f.round(2),
			full: firstItem.average(:totalpoint).to_f.round(2),
			count: firstItem.count(:totalpoint).to_i
		}
		@secondItem_result = {
			first: secondItem.average(:firstpoint).to_f.round(2),
			second: secondItem.average(:secondpoint).to_f.round(2),
			full: secondItem.average(:totalpoint).to_f.round(2),
			count: secondItem.count(:totalpoint).to_i
		}
		@thirdItem_result = {
			first: thirdItem.average(:firstpoint).to_f.round(2),
			second: thirdItem.average(:secondpoint).to_f.round(2),
			full: thirdItem.average(:totalpoint).to_f.round(2),
			count: thirdItem.count(:totalpoint).to_i
		}
		@forthItem_result = {
			first: forthItem.average(:firstpoint).to_f.round(2),
			second: forthItem.average(:secondpoint).to_f.round(2),
			full: forthItem.average(:totalpoint).to_f.round(2),
			count: forthItem.count(:totalpoint).to_i
		}
		if @game.home_first_quarter && @game.home_second_quarter && @game.away_first_quarter && @game.away_second_quarter
			@diff = @game.home_first_quarter + @game.home_second_quarter - @game.away_first_quarter - @game.away_second_quarter
		else
			@diff = 0
		end
		lastfirstItem = Fullseason.where(homediff: @diff-5..@diff+5)
		lastsecondItem = Fullseason.where("homefirsthalf > 60")
		lastthirdItem = Fullseason.where("roadfirsthalf > 60")
		@lastfirstItem_result = {
			first: lastfirstItem.average(:firstpoint).to_f.round(2),
			second: lastfirstItem.average(:secondpoint).to_f.round(2),
			full: lastfirstItem.average(:totalpoint).to_f.round(2),
			count: lastfirstItem.count(:totalpoint).to_i
		}
		@lastsecondItem_result = {
			first: lastsecondItem.average(:firstpoint).to_f.round(2),
			second: lastsecondItem.average(:secondpoint).to_f.round(2),
			full: lastsecondItem.average(:totalpoint).to_f.round(2),
			count: lastsecondItem.count(:totalpoint).to_i
		}
		@lastthirdItem_result = {
			first: lastthirdItem.average(:firstpoint).to_f.round(2),
			second: lastthirdItem.average(:secondpoint).to_f.round(2),
			full: lastthirdItem.average(:totalpoint).to_f.round(2),
			count: lastthirdItem.count(:totalpoint).to_i
		}

	end

	def stat
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
	    drtg_count = 0
	    drtg_min = 0
	    @away_players_group1.each_with_index do |player, index| 
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
	        drtg_count = drtg_count + 1
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @away_drtg_one = @away_drtg_one + player.drtg * player.sum_mins/(count - 2)
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    if drtg_count < 3
	    	@away_players_group4 = @away_last.players.where("team_abbr = ? AND state > 5 AND position = 'PG'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state > 5 AND position = 'SG'", @away_flag)).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	@away_players_group4.each_with_index do |player, index| 
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
		        compare = player.sum_mins/(count - 2)
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	one_value = player.drtg
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	two_value = player.drtg
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = player.drtg
		        end
		    end
		    if drtg_count < 3
			    drtg_min = drtg_min + max_one
			    @away_drtg_one = @away_drtg_one + one_value * max_one
			end
			if drtg_count < 2
			    drtg_min = drtg_min + max_two
			    @away_drtg_one = @away_drtg_one + two_value * max_two
			end
			if drtg_count < 1
			    drtg_min = drtg_min + max_thr
			    @away_drtg_one = @away_drtg_one + thr_value * max_thr
			end
	    	@away_drtg_one = @away_drtg_one.to_f / drtg_min
	    end

	    @away_drtg_two = 0
	    drtg_count = 0
	    drtg_min = 0
	    @away_players_group2.each_with_index do |player, index|
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
	        drtg_count = drtg_count + 1
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @away_drtg_two = @away_drtg_two + player.drtg * player.sum_mins/(count - 2)
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    if drtg_count < 3
	    	@away_players_group4 = @away_last.players.where("team_abbr = ? AND state > 5 AND position = 'C'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state > 5 AND position = 'SF'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state > 5 AND position = 'PF'", @away_flag))).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	@away_players_group4.each_with_index do |player, index| 
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
		        compare = player.sum_mins/(count - 2)
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	one_value = player.drtg
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	two_value = player.drtg
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = player.drtg
		        end
		    end
		    if drtg_count < 3
			    drtg_min = drtg_min + max_one
			    @away_drtg_two = @away_drtg_two + one_value * max_one
			end
			if drtg_count < 2
			    drtg_min = drtg_min + max_two
			    @away_drtg_two = @away_drtg_two + two_value * max_two
			end
			if drtg_count < 1
			    drtg_min = drtg_min + max_thr
			    @away_drtg_two = @away_drtg_two + thr_value * max_thr
			end
	    	@away_drtg_two = @away_drtg_two.to_f / drtg_min
	    end

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
	    drtg_count = 0
	    drtg_min = 0
	    @home_players_group1.each_with_index do |player, index| 
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
	        drtg_count = drtg_count + 1
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @home_drtg_one = @home_drtg_one + player.drtg * player.sum_mins/(count - 2)
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    if drtg_count < 3
	    	@home_players_group4 = @home_last.players.where("team_abbr = ? AND state > 5 AND position = 'PG'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'SG'", @home_flag)).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	@home_players_group4.each_with_index do |player, index| 
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
		        compare = player.sum_mins/(count - 2)
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	one_value = player.drtg
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	two_value = player.drtg
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = player.drtg
		        end
		    end
		    if drtg_count < 3
			    drtg_min = drtg_min + max_one
			    @home_drtg_one = @home_drtg_one + one_value * max_one
			end
			if drtg_count < 2
			    drtg_min = drtg_min + max_two
			    @home_drtg_one = @home_drtg_one + two_value * max_two
			end
			if drtg_count < 1
			    drtg_min = drtg_min + max_thr
			    @home_drtg_one = @home_drtg_one + thr_value * max_thr
			end
	    	@home_drtg_one = @home_drtg_one.to_f / drtg_min
	    end

	    @home_drtg_two = 0
	    drtg_count = 0
	    drtg_min = 0
	    @home_players_group2.each_with_index do |player, index| 
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
	        drtg_count = drtg_count + 1
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @home_drtg_two = @home_drtg_two + player.drtg * player.sum_mins/(count - 2)
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    if drtg_count < 3
	    	@home_players_group4 = @home_last.players.where("team_abbr = ? AND state > 5 AND position = 'C'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'SF'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'PF'", @home_flag))).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	@home_players_group4.each_with_index do |player, index| 
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
		        compare = player.sum_mins/(count - 2)
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	one_value = player.drtg
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	two_value = player.drtg
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = player.drtg
		        end
		    end
		    if drtg_count < 3
			    drtg_min = drtg_min + max_one
			    @home_drtg_two = @home_drtg_two + one_value * max_one
			end
			if drtg_count < 2
			    drtg_min = drtg_min + max_two
			    @home_drtg_two = @home_drtg_two + two_value * max_two
			end
			if drtg_count < 1
			    drtg_min = drtg_min + max_thr
			    @home_drtg_two = @home_drtg_two + thr_value * max_thr
			end
	    	@home_drtg_two = @home_drtg_two.to_f / drtg_min
	    end

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

		@countItem = Count.where("lastroad like ? AND nextroad like ? AND nexthome like ? AND lasthome like ?", "%#{@game.away_last_game}%", "%#{@game.away_next_game}%", "%#{@game.home_next_game}%", "%#{@game.home_last_game}%").first
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
