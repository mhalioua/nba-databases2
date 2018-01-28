class IndexController < ApplicationController
	before_action :confirm_logged_in
	def home
		@yesterday = Time.now - 1.days
    	@today = Time.now
    	@tomorrow = Time.now + 1.days
  	end

	def game
	  	unless params[:id]
	  	  	params[:id] = Time.now.strftime("%Y-%m-%d") + " - " + Time.now.strftime("%Y-%m-%d")
	  	end
		@game_index = params[:id]
	  	@game_start_index = @game_index[0..9]
	  	@game_end_index = @game_index[13..23]

  		@head = Date.strptime(@game_start_index, '%Y-%m-%d').strftime("%B %e")

	  	@games = Nba.where("game_date between ? and ?", Date.strptime(@game_start_index).beginning_of_day, Date.strptime(@game_end_index).end_of_day)
	  				.order("game_date", "home_number")
	end

	def referee
		if false
			@referee_filter_third = []
			(0..6).each do |one_element|
				@referee_filter_second = []
				(0..6).each do |two_element|
					@referee_filter_first = []
					(0..6).each do |three_element|
						search_array_last = []
						search_array_next = []
						if one_element > 5
							search_array_last.push("referee_one_last > 5")
							search_array_next.push("referee_one_next > 5")
						else
							search_array_last.push("referee_one_last = #{one_element}")
							search_array_next.push("referee_one_next = #{one_element}")
						end
						if two_element > 5
							search_array_last.push("referee_two_last > 5")
							search_array_next.push("referee_two_next > 5")
						else
							search_array_last.push("referee_two_last = #{two_element}")
							search_array_next.push("referee_two_next = #{two_element}")
						end
						if three_element > 5
							search_array_last.push("referee_three_last > 5")
							search_array_next.push("referee_three_next > 5")
						else
							search_array_last.push("referee_three_last = #{three_element}")
							search_array_next.push("referee_three_next = #{three_element}")
						end
						search_array_last = search_array_last.join(" AND ")
						search_array_next = search_array_next.join(" AND ")
						referee_filter_result_last = Referee.where(search_array_last)
						referee_filter_result_next = Referee.where(search_array_next)
						@referee_filter_first.push([
							referee_filter_result_last.count(:tp_1h).to_i,
							referee_filter_result_last.sum(:tp_1h).to_f.round(2),
							referee_filter_result_last.sum(:tp_2h).to_f.round(2),
							referee_filter_result_next.count(:tp_1h).to_i,
							referee_filter_result_next.sum(:tp_1h).to_f.round(2),
							referee_filter_result_next.sum(:tp_2h).to_f.round(2)
						])
					end
					@referee_filter_second.push(@referee_filter_first)
				end
				@referee_filter_third.push(@referee_filter_second)
			end
			@result = []
			(0..6).each do |one_element|
				(one_element..6).each do |two_element|
					start_element = two_element
					start_element = 0 if one_element == 0
					(start_element..6).each do |three_element|
						total_last_count = 0
						total_last_first = 0
						total_last_second = 0
						total_next_count = 0
						total_next_first = 0
						total_next_second = 0
						total_last_count = total_last_count + @referee_filter_third[one_element][two_element][three_element][0]
						total_last_count = total_last_count + @referee_filter_third[one_element][three_element][two_element][0]
						total_last_count = total_last_count + @referee_filter_third[two_element][one_element][three_element][0]
						total_last_count = total_last_count + @referee_filter_third[two_element][three_element][one_element][0]
						total_last_count = total_last_count + @referee_filter_third[three_element][one_element][two_element][0]
						total_last_count = total_last_count + @referee_filter_third[three_element][two_element][one_element][0]

						total_last_first = total_last_first + @referee_filter_third[one_element][two_element][three_element][1]
						total_last_first = total_last_first + @referee_filter_third[one_element][three_element][two_element][1]
						total_last_first = total_last_first + @referee_filter_third[two_element][one_element][three_element][1]
						total_last_first = total_last_first + @referee_filter_third[two_element][three_element][one_element][1]
						total_last_first = total_last_first + @referee_filter_third[three_element][one_element][two_element][1]
						total_last_first = total_last_first + @referee_filter_third[three_element][two_element][one_element][1]

						total_last_second = total_last_second + @referee_filter_third[one_element][two_element][three_element][2]
						total_last_second = total_last_second + @referee_filter_third[one_element][three_element][two_element][2]
						total_last_second = total_last_second + @referee_filter_third[two_element][one_element][three_element][2]
						total_last_second = total_last_second + @referee_filter_third[two_element][three_element][one_element][2]
						total_last_second = total_last_second + @referee_filter_third[three_element][one_element][two_element][2]
						total_last_second = total_last_second + @referee_filter_third[three_element][two_element][one_element][2]

						total_next_count = total_next_count + @referee_filter_third[one_element][two_element][three_element][3]
						total_next_count = total_next_count + @referee_filter_third[one_element][three_element][two_element][3]
						total_next_count = total_next_count + @referee_filter_third[two_element][one_element][three_element][3]
						total_next_count = total_next_count + @referee_filter_third[two_element][three_element][one_element][3]
						total_next_count = total_next_count + @referee_filter_third[three_element][one_element][two_element][3]
						total_next_count = total_next_count + @referee_filter_third[three_element][two_element][one_element][3]

						total_next_first = total_next_first + @referee_filter_third[one_element][two_element][three_element][4]
						total_next_first = total_next_first + @referee_filter_third[one_element][three_element][two_element][4]
						total_next_first = total_next_first + @referee_filter_third[two_element][one_element][three_element][4]
						total_next_first = total_next_first + @referee_filter_third[two_element][three_element][one_element][4]
						total_next_first = total_next_first + @referee_filter_third[three_element][one_element][two_element][4]
						total_next_first = total_next_first + @referee_filter_third[three_element][two_element][one_element][4]

						total_next_second = total_next_second + @referee_filter_third[one_element][two_element][three_element][5]
						total_next_second = total_next_second + @referee_filter_third[one_element][three_element][two_element][5]
						total_next_second = total_next_second + @referee_filter_third[two_element][one_element][three_element][5]
						total_next_second = total_next_second + @referee_filter_third[two_element][three_element][one_element][5]
						total_next_second = total_next_second + @referee_filter_third[three_element][one_element][two_element][5]
						total_next_second = total_next_second + @referee_filter_third[three_element][two_element][one_element][5]

						if one_element == two_element && two_element == three_element
							total_last_count = total_last_count / 6
							total_last_first = total_last_first / 6
							total_last_second = total_last_second / 6
							total_next_count = total_next_count / 6
							total_next_first = total_next_first / 6
							total_next_second = total_next_second / 6
						elsif one_element == two_element || two_element == three_element || one_element == three_element
							total_last_count = total_last_count / 2
							total_last_first = total_last_first / 2
							total_last_second = total_last_second / 2
							total_next_count = total_next_count / 2
							total_next_first = total_next_first / 2
							total_next_second = total_next_second / 2
						end
						total_last_first = total_last_first / total_last_count
						total_last_second = total_last_second / total_last_count
						total_next_first = total_next_first / total_next_count
						total_next_second = total_next_second / total_next_count
						
						@result.push([
							one_element,
							two_element,
							three_element,
							total_last_count,
							total_last_first.round(2),
							total_last_second.round(2),
							total_next_count,
							total_next_first.round(2),
							total_next_second.round(2)
						])
					end
				end
			end
		end
	end

	def detail
		@injuries = params[:injury]
		unless @injuries
			@injuries = ''
		end
		@injuries = @injuries.split(',')
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

		@date_id = Date.strptime(@game.game_date).strftime("%Y-%m-%d")

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


		@home_injury = Injury.where("team = ?", @game.home_team)
		@away_injury = Injury.where("team = ?", @game.away_team)

		@away_injury_name = []
		@away_injury.each_with_index do |injury, index|
			name = injury.name
			unless name.index('.')
				name_index = name.index(' ')
				name = name_index ? name[0] + '.' + name[name_index..-1] : name
			end
			if !injury.text.include?('probable') && !@injuries.include?(name)
				@away_injury_name.push(name)
			end
		end

		@home_injury_name = []
		@home_injury.each_with_index do |injury, index|
			name = injury.name
			unless name.index('.')
				name_index = name.index(' ')
				name = name_index ? name[0] + '.' + name[name_index..-1] : name
			end
			if !injury.text.include?('probable') && !@injuries.include?(name)
				@home_injury_name.push(name)
			end
		end

		@injury_away_total_poss = 0
	    @injury_away_total_min = 0
        @injury_away_total_stl = 0
        @injury_away_total_blk = 0
        @injury_away_total_or = 0
	    @injury_away_drtg_one = 0
	    injury_drtg_count = 0
	    injury_drtg_min = 0
	    @injury_away_drtg_one_container = []
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
	        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_away_total_min = @injury_away_total_min + player.sum_mins/(count - 2)
	        @injury_away_total_stl = @injury_away_total_stl + player.sum_stl/count
	        @injury_away_total_blk = @injury_away_total_blk + player.sum_blk/count
	        @injury_away_total_or = @injury_away_total_or + player.sum_or/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_away_drtg_one = @injury_away_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @injury_away_drtg_one_container.push(player.id)
	        @injury_away_total_poss = @injury_away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    if injury_drtg_count < 3
	    	@away_players_group4 = @away_last.players.where("team_abbr = ? AND state > 5 AND position = 'PG'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state > 5 AND position = 'SG'", @away_flag)).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	one_id = -1
	    	two_id = -1
	    	third_id = -1
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
		        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
		        	next
		        end
		        compare = player.sum_mins/(count - 2)
		        compare_value = player.drtg
		        compare_id = player.id
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	temp_drtg = one_value
		        	one_value = compare_value
		        	compare_value = temp_drtg
		        	temp = one_id
		        	one_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	temp_drtg = two_value
		        	two_value = compare_value
		        	compare_value = temp_drtg
		        	temp = two_id
		        	two_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = compare_value
		        	third_id = compare_id
		        end
		    end
		    if injury_drtg_count < 3
			    injury_drtg_min = injury_drtg_min + max_one
			    @injury_away_drtg_one = @injury_away_drtg_one + one_value * max_one
			    @injury_away_drtg_one_container.push(one_id)
			end
			if injury_drtg_count < 2
			    injury_drtg_min = injury_drtg_min + max_two
			    @injury_away_drtg_one = @injury_away_drtg_one + two_value * max_two
			    @injury_away_drtg_one_container.push(two_id)
			end
			if injury_drtg_count < 1
			    injury_drtg_min = injury_drtg_min + max_thr
			    @injury_away_drtg_one = @injury_away_drtg_one + thr_value * max_thr
			    @injury_away_drtg_one_container.push(third_id)
			end
	    end
	    @injury_away_drtg_one = @injury_away_drtg_one.to_f / injury_drtg_min

	    @injury_away_drtg_two = 0
	    injury_drtg_count = 0
	    injury_drtg_min = 0
	    @injury_away_drtg_two_container = []
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
	        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_away_total_min = @injury_away_total_min + player.sum_mins/(count - 2)
	        @injury_away_total_stl = @injury_away_total_stl + player.sum_stl/count
	        @injury_away_total_blk = @injury_away_total_blk + player.sum_blk/count
	        @injury_away_total_or = @injury_away_total_or + player.sum_or/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_away_drtg_two = @injury_away_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @injury_away_drtg_two_container.push(player.id)
	        @injury_away_total_poss = @injury_away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    if injury_drtg_count < 3
	    	@away_players_group4 = @away_last.players.where("team_abbr = ? AND state > 5 AND position = 'C'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state > 5 AND position = 'SF'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state > 5 AND position = 'PF'", @away_flag))).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	one_id = -1
	    	two_id = -1
	    	third_id = -1
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
		        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
		        	next
		        end
		        compare = player.sum_mins/(count - 2)
		        compare_value = player.drtg
		        compare_id = player.id
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	temp_drtg = one_value
		        	one_value = compare_value
		        	compare_value = temp_drtg
		        	temp = one_id
		        	one_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	temp_drtg = two_value
		        	two_value = compare_value
		        	compare_value = temp_drtg
		        	temp = two_id
		        	two_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = compare_value
		        	third_id = compare_id
		        end
		    end
		    if injury_drtg_count < 3
			    injury_drtg_min = injury_drtg_min + max_one
			    @injury_away_drtg_two = @injury_away_drtg_two + one_value * max_one
			    @injury_away_drtg_two_container.push(one_id)
			end
			if injury_drtg_count < 2
			    injury_drtg_min = injury_drtg_min + max_two
			    @injury_away_drtg_two = @injury_away_drtg_two + two_value * max_two
			    @injury_away_drtg_two_container.push(two_id)
			end
			if injury_drtg_count < 1
			    injury_drtg_min = injury_drtg_min + max_thr
			    @injury_away_drtg_two = @injury_away_drtg_two + thr_value * max_thr
			    @injury_away_drtg_two_container.push(third_id)
			end
	    end
	    @injury_away_drtg_two = @injury_away_drtg_two.to_f / injury_drtg_min

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
	        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        @injury_away_total_min = @injury_away_total_min + player.sum_mins/(count - 2)
	        @injury_away_total_stl = @injury_away_total_stl + player.sum_stl/count
	        @injury_away_total_blk = @injury_away_total_blk + player.sum_blk/count
	        @injury_away_total_or = @injury_away_total_or + player.sum_or/count
	        @injury_away_total_poss = @injury_away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    @injury_home_total_poss = 0
	    @injury_home_total_min = 0
        @injury_home_total_stl = 0
        @injury_home_total_blk = 0
        @injury_home_total_or = 0
	    @injury_home_drtg_one = 0
	    injury_drtg_count = 0
	    injury_drtg_min = 0
	    @injury_home_drtg_one_container = []
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
	        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_home_total_min = @injury_home_total_min + player.sum_mins/(count - 2)
	        @injury_home_total_stl = @injury_home_total_stl + player.sum_stl/count
	        @injury_home_total_blk = @injury_home_total_blk + player.sum_blk/count
	        @injury_home_total_or = @injury_home_total_or + player.sum_or/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_home_drtg_one = @injury_home_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @injury_home_total_poss = @injury_home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @injury_home_drtg_one_container.push(player.id)
	    end
	    if injury_drtg_count < 3
	    	@home_players_group4 = @home_last.players.where("team_abbr = ? AND state > 5 AND position = 'PG'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'SG'", @home_flag)).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	one_id = -1
	    	two_id = -1
	    	third_id = -1
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
		        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
		        	next
		        end
		        compare = player.sum_mins/(count - 2)
		        compare_value = player.drtg
		        compare_id = player.id
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	temp_drtg = one_value
		        	one_value = compare_value
		        	compare_value = temp_drtg
		        	temp = one_id
		        	one_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	temp_drtg = two_value
		        	two_value = compare_value
		        	compare_value = temp_drtg
		        	temp = two_id
		        	two_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = compare_value
		        	third_id = compare_id
		        end
		    end
		    if injury_drtg_count < 3
			    injury_drtg_min = injury_drtg_min + max_one
			    @injury_home_drtg_one = @injury_home_drtg_one + one_value * max_one
			    @injury_home_drtg_one_container.push(one_id)
			end
			if injury_drtg_count < 2
			    injury_drtg_min = injury_drtg_min + max_two
			    @injury_home_drtg_one = @injury_home_drtg_one + two_value * max_two
			    @injury_home_drtg_one_container.push(two_id)
			end
			if injury_drtg_count < 1
			    injury_drtg_min = injury_drtg_min + max_thr
			    @injury_home_drtg_one = @injury_home_drtg_one + thr_value * max_thr
			    @injury_home_drtg_one_container.push(third_id)
			end
	    end
	    @injury_home_drtg_one = @injury_home_drtg_one.to_f / injury_drtg_min

	    @injury_home_drtg_two = 0
	    injury_drtg_count = 0
	    injury_drtg_min = 0
	    @injury_home_drtg_two_container = []
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
	        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_home_total_min = @injury_home_total_min + player.sum_mins/(count - 2)
	        @injury_home_total_stl = @injury_home_total_stl + player.sum_stl/count
	        @injury_home_total_blk = @injury_home_total_blk + player.sum_blk/count
	        @injury_home_total_or = @injury_home_total_or + player.sum_or/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_home_drtg_two = @injury_home_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @injury_home_total_poss = @injury_home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @injury_home_drtg_two_container.push(player.id)
	    end
	    if injury_drtg_count < 3
	    	@home_players_group4 = @home_last.players.where("team_abbr = ? AND state > 5 AND position = 'C'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'SF'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'PF'", @home_flag))).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	one_id = -1
	    	two_id = -1
	    	third_id = -1
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
		        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
		        	next
		        end
		        compare = player.sum_mins/(count - 2)
		        compare_value = player.drtg
		        compare_id = player.id
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	temp_drtg = one_value
		        	one_value = compare_value
		        	compare_value = temp_drtg
		        	temp = one_id
		        	one_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	temp_drtg = two_value
		        	two_value = compare_value
		        	compare_value = temp_drtg
		        	temp = two_id
		        	two_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = compare_value
		        	third_id = compare_id
		        end
		    end
		    if injury_drtg_count < 3
			    injury_drtg_min = injury_drtg_min + max_one
			    @injury_home_drtg_two = @injury_home_drtg_two + one_value * max_one
			    @injury_home_drtg_two_container.push(one_id)
			end
			if injury_drtg_count < 2
			    injury_drtg_min = injury_drtg_min + max_two
			    @injury_home_drtg_two = @injury_home_drtg_two + two_value * max_two
			    @injury_home_drtg_two_container.push(two_id)
			end
			if injury_drtg_count < 1
			    injury_drtg_min = injury_drtg_min + max_thr
			    @injury_home_drtg_two = @injury_home_drtg_two + thr_value * max_thr
			    @injury_home_drtg_two_container.push(third_id)
			end
	    end
	    @injury_home_drtg_two = @injury_home_drtg_two.to_f / injury_drtg_min

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
	        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        @injury_home_total_min = @injury_home_total_min + player.sum_mins/(count - 2)
	        @injury_home_total_stl = @injury_home_total_stl + player.sum_stl/count
	        @injury_home_total_blk = @injury_home_total_blk + player.sum_blk/count
	        @injury_home_total_or = @injury_home_total_or + player.sum_or/count
	        @injury_home_total_poss = @injury_home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    @away_total_poss = 0
	    @away_total_min = 0
        @away_total_stl = 0
        @away_total_blk = 0
        @away_total_or = 0
	    @away_drtg_one = 0
	    drtg_count = 0
	    drtg_min = 0
	    @away_drtg_one_container = []
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
	        @away_total_stl = @away_total_stl + player.sum_stl/count
	        @away_total_blk = @away_total_blk + player.sum_blk/count
	        @away_total_or = @away_total_or + player.sum_or/count
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @away_drtg_one = @away_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @away_drtg_one_container.push(player.id)
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
	    	one_id = -1
	    	two_id = -1
	    	third_id = -1
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
		        compare_value = player.drtg
		        compare_id = player.id
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	temp_drtg = one_value
		        	one_value = compare_value
		        	compare_value = temp_drtg
		        	temp = one_id
		        	one_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	temp_drtg = two_value
		        	two_value = compare_value
		        	compare_value = temp_drtg
		        	temp = two_id
		        	two_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = compare_value
		        	third_id = compare_id
		        end
		    end
		    if drtg_count < 3
			    drtg_min = drtg_min + max_one
			    @away_drtg_one = @away_drtg_one + one_value * max_one
			    @away_drtg_one_container.push(one_id)
			end
			if drtg_count < 2
			    drtg_min = drtg_min + max_two
			    @away_drtg_one = @away_drtg_one + two_value * max_two
			    @away_drtg_one_container.push(two_id)
			end
			if drtg_count < 1
			    drtg_min = drtg_min + max_thr
			    @away_drtg_one = @away_drtg_one + thr_value * max_thr
			    @away_drtg_one_container.push(third_id)
			end
	    end
	    @away_drtg_one = @away_drtg_one.to_f / drtg_min

	    @away_drtg_two = 0
	    drtg_count = 0
	    drtg_min = 0
	    @away_drtg_two_container = []
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
	        @away_total_stl = @away_total_stl + player.sum_stl/count
	        @away_total_blk = @away_total_blk + player.sum_blk/count
	        @away_total_or = @away_total_or + player.sum_or/count
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @away_drtg_two = @away_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @away_drtg_two_container.push(player.id)
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
	    	one_id = -1
	    	two_id = -1
	    	third_id = -1
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
		        compare_value = player.drtg
		        compare_id = player.id
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	temp_drtg = one_value
		        	one_value = compare_value
		        	compare_value = temp_drtg
		        	temp = one_id
		        	one_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	temp_drtg = two_value
		        	two_value = compare_value
		        	compare_value = temp_drtg
		        	temp = two_id
		        	two_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = compare_value
		        	third_id = compare_id
		        end
		    end
		    if drtg_count < 3
			    drtg_min = drtg_min + max_one
			    @away_drtg_two = @away_drtg_two + one_value * max_one
			    @away_drtg_two_container.push(one_id)
			end
			if drtg_count < 2
			    drtg_min = drtg_min + max_two
			    @away_drtg_two = @away_drtg_two + two_value * max_two
			    @away_drtg_two_container.push(two_id)
			end
			if drtg_count < 1
			    drtg_min = drtg_min + max_thr
			    @away_drtg_two = @away_drtg_two + thr_value * max_thr
			    @away_drtg_two_container.push(third_id)
			end
	    end
	    @away_drtg_two = @away_drtg_two.to_f / drtg_min

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
	        @away_total_stl = @away_total_stl + player.sum_stl/count
	        @away_total_blk = @away_total_blk + player.sum_blk/count
	        @away_total_or = @away_total_or + player.sum_or/count
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    @home_total_poss = 0
	    @home_total_min = 0
        @home_total_stl = 0
        @home_total_blk = 0
        @home_total_or = 0
	    @home_drtg_one = 0
	    drtg_count = 0
	    drtg_min = 0
	    @home_drtg_one_container = []
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
	        @home_total_stl = @home_total_stl + player.sum_stl/count
	        @home_total_blk = @home_total_blk + player.sum_blk/count
	        @home_total_or = @home_total_or + player.sum_or/count
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @home_drtg_one = @home_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @home_drtg_one_container.push(player.id)
	    end
	    if drtg_count < 3
	    	@home_players_group4 = @home_last.players.where("team_abbr = ? AND state > 5 AND position = 'PG'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'SG'", @home_flag)).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	one_id = -1
	    	two_id = -1
	    	third_id = -1
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
		        compare_value = player.drtg
		        compare_id = player.id
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	temp_drtg = one_value
		        	one_value = compare_value
		        	compare_value = temp_drtg
		        	temp = one_id
		        	one_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	temp_drtg = two_value
		        	two_value = compare_value
		        	compare_value = temp_drtg
		        	temp = two_id
		        	two_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = compare_value
		        	third_id = compare_id
		        end
		    end
		    if drtg_count < 3
			    drtg_min = drtg_min + max_one
			    @home_drtg_one = @home_drtg_one + one_value * max_one
			    @home_drtg_one_container.push(one_id)
			end
			if drtg_count < 2
			    drtg_min = drtg_min + max_two
			    @home_drtg_one = @home_drtg_one + two_value * max_two
			    @home_drtg_one_container.push(two_id)
			end
			if drtg_count < 1
			    drtg_min = drtg_min + max_thr
			    @home_drtg_one = @home_drtg_one + thr_value * max_thr
			    @home_drtg_one_container.push(third_id)
			end
	    end
	    @home_drtg_one = @home_drtg_one.to_f / drtg_min

	    @home_drtg_two = 0
	    drtg_count = 0
	    drtg_min = 0
	    @home_drtg_two_container = []
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
	        @home_total_stl = @home_total_stl + player.sum_stl/count
	        @home_total_blk = @home_total_blk + player.sum_blk/count
	        @home_total_or = @home_total_or + player.sum_or/count
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @home_drtg_two = @home_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @home_drtg_two_container.push(player.id)
	    end
	    if drtg_count < 3
	    	@home_players_group4 = @home_last.players.where("team_abbr = ? AND state > 5 AND position = 'C'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'SF'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'PF'", @home_flag))).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	one_id = -1
	    	two_id = -1
	    	third_id = -1
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
		        compare_value = player.drtg
		        compare_id = player.id
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	temp_drtg = one_value
		        	one_value = compare_value
		        	compare_value = temp_drtg
		        	temp = one_id
		        	one_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	temp_drtg = two_value
		        	two_value = compare_value
		        	compare_value = temp_drtg
		        	temp = two_id
		        	two_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = compare_value
		        	third_id = compare_id
		        end
		    end
		    if drtg_count < 3
			    drtg_min = drtg_min + max_one
			    @home_drtg_two = @home_drtg_two + one_value * max_one
			    @home_drtg_two_container.push(one_id)
			end
			if drtg_count < 2
			    drtg_min = drtg_min + max_two
			    @home_drtg_two = @home_drtg_two + two_value * max_two
			    @home_drtg_two_container.push(two_id)
			end
			if drtg_count < 1
			    drtg_min = drtg_min + max_thr
			    @home_drtg_two = @home_drtg_two + thr_value * max_thr
			    @home_drtg_two_container.push(third_id)
			end
	    end
	    @home_drtg_two = @home_drtg_two.to_f / drtg_min

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
	        @home_total_stl = @home_total_stl + player.sum_stl/count
	        @home_total_blk = @home_total_blk + player.sum_blk/count
	        @home_total_or = @home_total_or + player.sum_or/count
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end


	    @filters = [
	    	[false, false, false, false, false, false, false, false],
	    	[true, true, true, true, true, true, true, true],
	    	[false, true, true, true, true, true, true, true],
	    	[true, false, true, true, true, true, true, true],
	    	[true, true, false, true, true, true, true, true],
	    	[true, true, true, false, true, true, true, true],
	    	[true, true, true, true, false, true, true, true],
	    	[true, true, true, true, true, false, true, true],
	    	[true, true, true, true, true, true, false, true],
	    	[true, true, true, true, true, true, true, false],
	    	[true, true, false, true, true, false, true, true],
	    	[true, true, true, false, false, true, true, true],
	    	[false, false, true, true, true, true, true, true],
	    	[true, true, true, true, true, true, false, false],
	    	[false, true, true, true, true, true, true, false],
	    	[true, false, true, true, true, true, false, true],
	    	[false, false, true, true, true, true, false, false],
	    	[true, true, true, true, false, false, false, false],
	    	[false, false, false, false, true, true, true, true],
	    	[false, true, false, true, true, false, true, false]
		]
		@break = [9, 15, 16]
		@filterResult = []
		@filters.each_with_index do |filter, index|
			search_string = []
			search_second_string = []
			if filter[0]
				search_string.push("awaylastfly = '#{@game.away_last_fly}'")
				search_second_string.push("awaylastfly = '#{@game.away_last_fly}'")
				filter[0] = @game.away_last_fly[0]
			else
				search_string.push("awaylastfly <> '#{@game.away_last_fly}'")
			end
			if filter[1]
				search_string.push("awaynextfly = '#{@game.away_next_fly}'")
				search_second_string.push("awaynextfly = '#{@game.away_next_fly}'")
				filter[1] = @game.away_next_fly[0]
			else
				search_string.push("awaynextfly <> '#{@game.away_next_fly}'")
			end
			if filter[2]
				search_string.push("roadlast = '#{@game.away_last_game}'")
				search_second_string.push("roadlast = '#{@game.away_last_game}'")
				filter[2] = @game.away_last_game
			else
				search_string.push("roadlast <> '#{@game.away_last_game}'")
			end
			if filter[3]
				search_string.push("roadnext = '#{@game.away_next_game}'")
				search_second_string.push("roadnext = '#{@game.away_next_game}'")
				filter[3] = @game.away_next_game
			else
				search_string.push("roadnext <> '#{@game.away_next_game}'")
			end
			if filter[4]
				search_string.push("homenext = '#{@game.home_next_game}'")
				search_second_string.push("homenext = '#{@game.home_next_game}'")
				filter[4] = @game.home_next_game
			else
				search_string.push("homenext <> '#{@game.home_next_game}'")
			end
			if filter[5]
				search_string.push("homelast = '#{@game.home_last_game}'")
				search_second_string.push("homelast = '#{@game.home_last_game}'")
				filter[5] = @game.home_last_game
			else
				search_string.push("homelast <> '#{@game.home_last_game}'")
			end
			if filter[6]
				search_string.push("homenextfly = '#{@game.home_next_fly}'")
				search_second_string.push("homenextfly = '#{@game.home_next_fly}'")
				filter[6] = @game.home_next_fly[0]
			else
				search_string.push("homenextfly <> '#{@game.home_next_fly}'")
			end
			if filter[7]
				search_string.push("homelastfly = '#{@game.home_last_fly}'")
				search_second_string.push("homelastfly = '#{@game.home_last_fly}'")
				filter[7] = @game.home_last_fly[0]
			else
				search_string.push("homelastfly <> '#{@game.home_last_fly}'")
			end
			search_string = search_string.join(" AND ")
			search_second_string = search_second_string.join(" AND ")
			filter_element = Fullseason.where(search_string)
			filter_second_element = Fullseason.where(search_second_string)
			result_element = {
				first: filter_element.average(:firstvalue).to_f.round(2),
				second: filter_element.average(:secondvalue).to_f.round(2),
				full: filter_element.average(:totalvalue).to_f.round(2),
				count: filter_element.count(:totalvalue).to_i,
				allfirst: filter_second_element.average(:firstvalue).to_f.round(2),
				allsecond: filter_second_element.average(:secondvalue).to_f.round(2),
				allfull: filter_second_element.average(:totalvalue).to_f.round(2),
				allcount: filter_second_element.count(:totalvalue).to_i,
				home_ortg: filter_second_element.average(:home_ortg).to_f.round(2),
				away_ortg: filter_second_element.average(:away_ortg).to_f.round(2),
				bi: ((filter_second_element.average(:home_win_rank).to_f.round(2)-filter_second_element.average(:away_win_rank).to_f.round(2))/2-3).round(2),
				bj: filter_second_element.average(:fgside).to_f.round(2),
				bg: filter_second_element.average(:firstside).to_f.round(2),
				bh: filter_second_element.average(:secondside).to_f.round(2),
				away_fg_percent: filter_second_element.average(:away_fg_percent).to_f.round(2),
				home_fg_percent: filter_second_element.average(:home_fg_percent).to_f.round(2)
			}
			if index < 2 || index > 13
				result_element[:full_first] = (filter_second_element.average(:roadthird).to_f + filter_second_element.average(:roadforth).to_f + filter_second_element.average(:roadfirsthalf).to_f).round(2)
				result_element[:full_second] = (filter_second_element.average(:homethird).to_f + filter_second_element.average(:homeforth).to_f + filter_second_element.average(:homefirsthalf).to_f).round(2)
				result_element[:firsthalf_first] = filter_second_element.average(:roadfirsthalf).to_f.round(2)
				result_element[:firsthalf_second] = filter_second_element.average(:homefirsthalf).to_f.round(2)
				result_element[:secondhalf_first] = (filter_second_element.average(:roadthird).to_f.round(2) + filter_second_element.average(:roadforth).to_f.round(2)).round(2)
				result_element[:secondhalf_second] = (filter_second_element.average(:homethird).to_f.round(2) + filter_second_element.average(:homeforth).to_f.round(2)).round(2)
			end
			@filterResult.push(result_element)
		end
		@home_team_info = Team.find_by(abbr: @home_abbr)
    	@away_team_info = Team.find_by(abbr: @away_abbr)
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
		@countItem = Fullseason.where("awaylastfly = ? AND awaynextfly = ? AND roadlast = ? AND roadnext = ? AND homenext = ? AND homelast = ? AND homenextfly = ? AND homelastfly = ?", @game.away_last_fly, @game.away_next_fly, @game.away_last_game, @game.away_next_game, @game.home_next_game, @game.home_last_game, @game.home_next_fly, @game.home_last_fly)
		@compares = @game.compares.all

		referee_one_last = @game.referee_one_last
		referee_one_next = @game.referee_one_next
		referee_two_last = @game.referee_two_last
		referee_two_next = @game.referee_two_next
		referee_three_last = @game.referee_three_last
		referee_three_next = @game.referee_three_next
		@referee_last_type = 3
		@referee_next_type = 3

		@referee_filter = []
		if referee_one_last == nil || referee_two_last == nil || referee_three_last == nil
			@referee_last_type = 0
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
		elsif referee_one_last == referee_two_last && referee_two_last == referee_three_last
			@referee_last_type = 1
			@referee_filter.push([referee_one_last, referee_one_last, referee_one_last])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
		elsif referee_one_last == referee_two_last || referee_two_last == referee_three_last || referee_one_last == referee_three_last
			@referee_last_type = 2
			one_value = 0
			two_value = 0
			if referee_one_last == referee_two_last
				one_value = referee_one_last
				two_value = referee_three_last
			elsif referee_two_last == referee_three_last
				one_value = referee_two_last
				two_value = referee_one_last
			elsif referee_one_last == referee_three_last
				one_value = referee_one_last
				two_value = referee_two_last
			end

			@referee_filter.push([one_value, one_value, two_value])
			@referee_filter.push([one_value, two_value, one_value])
			@referee_filter.push([two_value, one_value, one_value])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
		else
			@referee_last_type = 3
			@referee_filter.push([referee_one_last, referee_two_last, referee_three_last])
			@referee_filter.push([referee_one_last, referee_three_last, referee_two_last])
			@referee_filter.push([referee_two_last, referee_one_last, referee_three_last])
			@referee_filter.push([referee_two_last, referee_three_last, referee_one_last])
			@referee_filter.push([referee_three_last, referee_one_last, referee_two_last])
			@referee_filter.push([referee_three_last, referee_two_last, referee_one_last])
		end

		if referee_one_next == nil || referee_two_next == nil || referee_three_next == nil
			@referee_next_type = 0
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
		elsif referee_one_next == referee_two_next && referee_two_next == referee_three_next
			@referee_next_type = 1
			@referee_filter.push([referee_one_next, referee_one_next, referee_one_next])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
		elsif referee_one_next == referee_two_next || referee_two_next == referee_three_next || referee_one_next == referee_three_next
			@referee_next_type = 2
			one_value = 0
			two_value = 0
			if referee_one_next == referee_two_next
				one_value = referee_one_next
				two_value = referee_three_next
			elsif referee_two_next == referee_three_next
				one_value = referee_two_next
				two_value = referee_one_next
			elsif referee_one_next == referee_three_next
				one_value = referee_one_next
				two_value = referee_two_next
			end

			@referee_filter.push([one_value, one_value, two_value])
			@referee_filter.push([one_value, two_value, one_value])
			@referee_filter.push([two_value, one_value, one_value])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
			@referee_filter.push(['-', '-', '-'])
		else
			@referee_next_type = 3
			@referee_filter.push([referee_one_next, referee_two_next, referee_three_next])
			@referee_filter.push([referee_one_next, referee_three_next, referee_two_next])
			@referee_filter.push([referee_two_next, referee_one_next, referee_three_next])
			@referee_filter.push([referee_two_next, referee_three_next, referee_one_next])
			@referee_filter.push([referee_three_next, referee_one_next, referee_two_next])
			@referee_filter.push([referee_three_next, referee_two_next, referee_one_next])
		end

		@referee_filter_results = []

		@referee_filter.each_with_index do |referee_filter_element, index|
			if referee_filter_element[0] != '-'
				search_array = []
				if index < 6
					if referee_filter_element[0] > 5
						search_array.push("referee_one_last > 5")
					else
						search_array.push("referee_one_last = #{referee_filter_element[0]}")
					end
					if referee_filter_element[1] > 5
						search_array.push("referee_two_last > 5")
					else
						search_array.push("referee_two_last = #{referee_filter_element[1]}")
					end
					if referee_filter_element[2] > 5
						search_array.push("referee_three_last > 5")
					else
						search_array.push("referee_three_last = #{referee_filter_element[2]}")
					end
				else
					if referee_filter_element[0] > 5
						search_array.push("referee_one_next > 5")
					else
						search_array.push("referee_one_next = #{referee_filter_element[0]}")
					end
					if referee_filter_element[1] > 5
						search_array.push("referee_two_next > 5")
					else
						search_array.push("referee_two_next = #{referee_filter_element[1]}")
					end
					if referee_filter_element[2] > 5
						search_array.push("referee_three_next > 5")
					else
						search_array.push("referee_three_next = #{referee_filter_element[2]}")
					end
				end
				search_array = search_array.join(" AND ")
				referee_filter_result = Referee.where(search_array)
				@referee_filter_results.push([
					referee_filter_result.average(:tp_1h).to_f.round(2),
					referee_filter_result.average(:tp_2h).to_f.round(2),
					referee_filter_result.count(:tp_1h).to_i
				])
			else
				@referee_filter_results.push(['-', '-',	'-'])
			end
		end
	end

	def state
		@injuries = params[:injury]
		unless @injuries
			@injuries = ''
		end
		@injuries = @injuries.split(',')
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

		@date_id = Date.strptime(@game.game_date).strftime("%Y-%m-%d")

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


		@home_injury = Injury.where("team = ?", @game.home_team)
		@away_injury = Injury.where("team = ?", @game.away_team)

		@away_injury_name = []
		@away_injury.each_with_index do |injury, index|
			name = injury.name
			unless name.index('.')
				name_index = name.index(' ')
				name = name_index ? name[0] + '.' + name[name_index..-1] : name
			end
			if !injury.text.include?('probable') && !@injuries.include?(name)
				@away_injury_name.push(name)
			end
		end

		@home_injury_name = []
		@home_injury.each_with_index do |injury, index|
			name = injury.name
			unless name.index('.')
				name_index = name.index(' ')
				name = name_index ? name[0] + '.' + name[name_index..-1] : name
			end
			if !injury.text.include?('probable') && !@injuries.include?(name)
				@home_injury_name.push(name)
			end
		end

		@injury_away_total_poss = 0
	    @injury_away_total_min = 0
        @injury_away_total_stl = 0
        @injury_away_total_blk = 0
        @injury_away_total_or = 0
	    @injury_away_drtg_one = 0
	    injury_drtg_count = 0
	    injury_drtg_min = 0
	    @injury_away_drtg_one_container = []
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
	        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_away_total_min = @injury_away_total_min + player.sum_mins/(count - 2)
	        @injury_away_total_stl = @injury_away_total_stl + player.sum_stl/count
	        @injury_away_total_blk = @injury_away_total_blk + player.sum_blk/count
	        @injury_away_total_or = @injury_away_total_or + player.sum_or/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_away_drtg_one = @injury_away_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @injury_away_drtg_one_container.push(player.id)
	        @injury_away_total_poss = @injury_away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    if injury_drtg_count < 3
	    	@away_players_group4 = @away_last.players.where("team_abbr = ? AND state > 5 AND position = 'PG'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state > 5 AND position = 'SG'", @away_flag)).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	one_id = -1
	    	two_id = -1
	    	third_id = -1
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
		        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
		        	next
		        end
		        compare = player.sum_mins/(count - 2)
		        compare_value = player.drtg
		        compare_id = player.id
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	temp_drtg = one_value
		        	one_value = compare_value
		        	compare_value = temp_drtg
		        	temp = one_id
		        	one_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	temp_drtg = two_value
		        	two_value = compare_value
		        	compare_value = temp_drtg
		        	temp = two_id
		        	two_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = compare_value
		        	third_id = compare_id
		        end
		    end
		    if injury_drtg_count < 3
			    injury_drtg_min = injury_drtg_min + max_one
			    @injury_away_drtg_one = @injury_away_drtg_one + one_value * max_one
			    @injury_away_drtg_one_container.push(one_id)
			end
			if injury_drtg_count < 2
			    injury_drtg_min = injury_drtg_min + max_two
			    @injury_away_drtg_one = @injury_away_drtg_one + two_value * max_two
			    @injury_away_drtg_one_container.push(two_id)
			end
			if injury_drtg_count < 1
			    injury_drtg_min = injury_drtg_min + max_thr
			    @injury_away_drtg_one = @injury_away_drtg_one + thr_value * max_thr
			    @injury_away_drtg_one_container.push(third_id)
			end
	    end
	    @injury_away_drtg_one = @injury_away_drtg_one.to_f / injury_drtg_min

	    @injury_away_drtg_two = 0
	    injury_drtg_count = 0
	    injury_drtg_min = 0
	    @injury_away_drtg_two_container = []
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
	        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_away_total_min = @injury_away_total_min + player.sum_mins/(count - 2)
	        @injury_away_total_stl = @injury_away_total_stl + player.sum_stl/count
	        @injury_away_total_blk = @injury_away_total_blk + player.sum_blk/count
	        @injury_away_total_or = @injury_away_total_or + player.sum_or/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_away_drtg_two = @injury_away_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @injury_away_drtg_two_container.push(player.id)
	        @injury_away_total_poss = @injury_away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    if injury_drtg_count < 3
	    	@away_players_group4 = @away_last.players.where("team_abbr = ? AND state > 5 AND position = 'C'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state > 5 AND position = 'SF'", @away_flag).or(@away_last.players.where("team_abbr = ? AND state > 5 AND position = 'PF'", @away_flag))).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	one_id = -1
	    	two_id = -1
	    	third_id = -1
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
		        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
		        	next
		        end
		        compare = player.sum_mins/(count - 2)
		        compare_value = player.drtg
		        compare_id = player.id
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	temp_drtg = one_value
		        	one_value = compare_value
		        	compare_value = temp_drtg
		        	temp = one_id
		        	one_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	temp_drtg = two_value
		        	two_value = compare_value
		        	compare_value = temp_drtg
		        	temp = two_id
		        	two_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = compare_value
		        	third_id = compare_id
		        end
		    end
		    if injury_drtg_count < 3
			    injury_drtg_min = injury_drtg_min + max_one
			    @injury_away_drtg_two = @injury_away_drtg_two + one_value * max_one
			    @injury_away_drtg_two_container.push(one_id)
			end
			if injury_drtg_count < 2
			    injury_drtg_min = injury_drtg_min + max_two
			    @injury_away_drtg_two = @injury_away_drtg_two + two_value * max_two
			    @injury_away_drtg_two_container.push(two_id)
			end
			if injury_drtg_count < 1
			    injury_drtg_min = injury_drtg_min + max_thr
			    @injury_away_drtg_two = @injury_away_drtg_two + thr_value * max_thr
			    @injury_away_drtg_two_container.push(third_id)
			end
	    end
	    @injury_away_drtg_two = @injury_away_drtg_two.to_f / injury_drtg_min

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
	        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        @injury_away_total_min = @injury_away_total_min + player.sum_mins/(count - 2)
	        @injury_away_total_stl = @injury_away_total_stl + player.sum_stl/count
	        @injury_away_total_blk = @injury_away_total_blk + player.sum_blk/count
	        @injury_away_total_or = @injury_away_total_or + player.sum_or/count
	        @injury_away_total_poss = @injury_away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    @injury_home_total_poss = 0
	    @injury_home_total_min = 0
        @injury_home_total_stl = 0
        @injury_home_total_blk = 0
        @injury_home_total_or = 0
	    @injury_home_drtg_one = 0
	    injury_drtg_count = 0
	    injury_drtg_min = 0
	    @injury_home_drtg_one_container = []
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
	        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_home_total_min = @injury_home_total_min + player.sum_mins/(count - 2)
	        @injury_home_total_stl = @injury_home_total_stl + player.sum_stl/count
	        @injury_home_total_blk = @injury_home_total_blk + player.sum_blk/count
	        @injury_home_total_or = @injury_home_total_or + player.sum_or/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_home_drtg_one = @injury_home_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @injury_home_total_poss = @injury_home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @injury_home_drtg_one_container.push(player.id)
	    end
	    if injury_drtg_count < 3
	    	@home_players_group4 = @home_last.players.where("team_abbr = ? AND state > 5 AND position = 'PG'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'SG'", @home_flag)).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	one_id = -1
	    	two_id = -1
	    	third_id = -1
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
		        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
		        	next
		        end
		        compare = player.sum_mins/(count - 2)
		        compare_value = player.drtg
		        compare_id = player.id
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	temp_drtg = one_value
		        	one_value = compare_value
		        	compare_value = temp_drtg
		        	temp = one_id
		        	one_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	temp_drtg = two_value
		        	two_value = compare_value
		        	compare_value = temp_drtg
		        	temp = two_id
		        	two_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = compare_value
		        	third_id = compare_id
		        end
		    end
		    if injury_drtg_count < 3
			    injury_drtg_min = injury_drtg_min + max_one
			    @injury_home_drtg_one = @injury_home_drtg_one + one_value * max_one
			    @injury_home_drtg_one_container.push(one_id)
			end
			if injury_drtg_count < 2
			    injury_drtg_min = injury_drtg_min + max_two
			    @injury_home_drtg_one = @injury_home_drtg_one + two_value * max_two
			    @injury_home_drtg_one_container.push(two_id)
			end
			if injury_drtg_count < 1
			    injury_drtg_min = injury_drtg_min + max_thr
			    @injury_home_drtg_one = @injury_home_drtg_one + thr_value * max_thr
			    @injury_home_drtg_one_container.push(third_id)
			end
	    end
	    @injury_home_drtg_one = @injury_home_drtg_one.to_f / injury_drtg_min

	    @injury_home_drtg_two = 0
	    injury_drtg_count = 0
	    injury_drtg_min = 0
	    @injury_home_drtg_two_container = []
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
	        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_home_total_min = @injury_home_total_min + player.sum_mins/(count - 2)
	        @injury_home_total_stl = @injury_home_total_stl + player.sum_stl/count
	        @injury_home_total_blk = @injury_home_total_blk + player.sum_blk/count
	        @injury_home_total_or = @injury_home_total_or + player.sum_or/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_home_drtg_two = @injury_home_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @injury_home_total_poss = @injury_home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @injury_home_drtg_two_container.push(player.id)
	    end
	    if injury_drtg_count < 3
	    	@home_players_group4 = @home_last.players.where("team_abbr = ? AND state > 5 AND position = 'C'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'SF'", @home_flag).or(@home_last.players.where("team_abbr = ? AND state > 5 AND position = 'PF'", @home_flag))).order(:state)
	    	max_one = 0
	    	one_value = 0
	    	max_two = 0
	    	two_value = 0
	    	max_thr = 0
	    	thr_value = 0
	    	one_id = -1
	    	two_id = -1
	    	third_id = -1
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
		        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
		        	next
		        end
		        compare = player.sum_mins/(count - 2)
		        compare_value = player.drtg
		        compare_id = player.id
		        if compare > max_one
		        	temp = max_one
		        	max_one = compare
		        	compare = temp
		        	temp_drtg = one_value
		        	one_value = compare_value
		        	compare_value = temp_drtg
		        	temp = one_id
		        	one_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_two
		        	temp = max_two
		        	max_two = compare
		        	compare = temp
		        	temp_drtg = two_value
		        	two_value = compare_value
		        	compare_value = temp_drtg
		        	temp = two_id
		        	two_id = compare_id
		        	compare_id = temp
		        end
		        if compare > max_thr
		        	max_thr = compare
		        	thr_value = compare_value
		        	third_id = compare_id
		        end
		    end
		    if injury_drtg_count < 3
			    injury_drtg_min = injury_drtg_min + max_one
			    @injury_home_drtg_two = @injury_home_drtg_two + one_value * max_one
			    @injury_home_drtg_two_container.push(one_id)
			end
			if injury_drtg_count < 2
			    injury_drtg_min = injury_drtg_min + max_two
			    @injury_home_drtg_two = @injury_home_drtg_two + two_value * max_two
			    @injury_home_drtg_two_container.push(two_id)
			end
			if injury_drtg_count < 1
			    injury_drtg_min = injury_drtg_min + max_thr
			    @injury_home_drtg_two = @injury_home_drtg_two + thr_value * max_thr
			    @injury_home_drtg_two_container.push(third_id)
			end
	    end
	    @injury_home_drtg_two = @injury_home_drtg_two.to_f / injury_drtg_min

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
	        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        @injury_home_total_min = @injury_home_total_min + player.sum_mins/(count - 2)
	        @injury_home_total_stl = @injury_home_total_stl + player.sum_stl/count
	        @injury_home_total_blk = @injury_home_total_blk + player.sum_blk/count
	        @injury_home_total_or = @injury_home_total_or + player.sum_or/count
	        @injury_home_total_poss = @injury_home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

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

		@date_id = Date.strptime(@game.game_date).strftime("%Y-%m-%d")

		@away_players = @away_last.players.where("team_abbr = ?", @away_flag).order(:state)
		@away_players = @away_players[0..-2]

		@home_players = @home_last.players.where("team_abbr = ?", @home_flag).order(:state)
		@home_players = @home_players[0..-2]


	    @filters = [
	    	[false, false, false, false, false, false, false, false],
	    	[true, true, true, true, true, true, true, true],
	    	[false, true, true, true, true, true, true, true],
	    	[true, false, true, true, true, true, true, true],
	    	[true, true, false, true, true, true, true, true],
	    	[true, true, true, false, true, true, true, true],
	    	[true, true, true, true, false, true, true, true],
	    	[true, true, true, true, true, false, true, true],
	    	[true, true, true, true, true, true, false, true],
	    	[true, true, true, true, true, true, true, false],
	    	[true, true, false, true, true, false, true, true],
	    	[true, true, true, false, false, true, true, true],
	    	[false, false, true, true, true, true, true, true],
	    	[true, true, true, true, true, true, false, false],
	    	[false, true, true, true, true, true, true, false],
	    	[true, false, true, true, true, true, false, true],
	    	[false, false, true, true, true, true, false, false],
	    	[true, true, true, true, false, false, false, false],
	    	[false, false, false, false, true, true, true, true],
	    	[false, true, false, true, true, false, true, false]
		]
		@break = [9, 15, 16]
		@filterResult = []
		@filters.each_with_index do |filter, index|
			search_string = []
			search_second_string = []
			if filter[0]
				search_string.push("awaylastfly = '#{@game.away_last_fly}'")
				search_second_string.push("awaylastfly = '#{@game.away_last_fly}'")
				filter[0] = @game.away_last_fly[0]
			else
				search_string.push("awaylastfly <> '#{@game.away_last_fly}'")
			end
			if filter[1]
				search_string.push("awaynextfly = '#{@game.away_next_fly}'")
				search_second_string.push("awaynextfly = '#{@game.away_next_fly}'")
				filter[1] = @game.away_next_fly[0]
			else
				search_string.push("awaynextfly <> '#{@game.away_next_fly}'")
			end
			if filter[2]
				search_string.push("roadlast = '#{@game.away_last_game}'")
				search_second_string.push("roadlast = '#{@game.away_last_game}'")
				filter[2] = @game.away_last_game
			else
				search_string.push("roadlast <> '#{@game.away_last_game}'")
			end
			if filter[3]
				search_string.push("roadnext = '#{@game.away_next_game}'")
				search_second_string.push("roadnext = '#{@game.away_next_game}'")
				filter[3] = @game.away_next_game
			else
				search_string.push("roadnext <> '#{@game.away_next_game}'")
			end
			if filter[4]
				search_string.push("homenext = '#{@game.home_next_game}'")
				search_second_string.push("homenext = '#{@game.home_next_game}'")
				filter[4] = @game.home_next_game
			else
				search_string.push("homenext <> '#{@game.home_next_game}'")
			end
			if filter[5]
				search_string.push("homelast = '#{@game.home_last_game}'")
				search_second_string.push("homelast = '#{@game.home_last_game}'")
				filter[5] = @game.home_last_game
			else
				search_string.push("homelast <> '#{@game.home_last_game}'")
			end
			if filter[6]
				search_string.push("homenextfly = '#{@game.home_next_fly}'")
				search_second_string.push("homenextfly = '#{@game.home_next_fly}'")
				filter[6] = @game.home_next_fly[0]
			else
				search_string.push("homenextfly <> '#{@game.home_next_fly}'")
			end
			if filter[7]
				search_string.push("homelastfly = '#{@game.home_last_fly}'")
				search_second_string.push("homelastfly = '#{@game.home_last_fly}'")
				filter[7] = @game.home_last_fly[0]
			else
				search_string.push("homelastfly <> '#{@game.home_last_fly}'")
			end
			search_string = search_string.join(" AND ")
			search_second_string = search_second_string.join(" AND ")
			filter_element = Fullseason.where(search_string)
			filter_second_element = Fullseason.where(search_second_string)
			result_element = {
				first: filter_element.average(:firstvalue).to_f.round(2),
				second: filter_element.average(:secondvalue).to_f.round(2),
				full: filter_element.average(:totalvalue).to_f.round(2),
				count: filter_element.count(:totalvalue).to_i,
				allfirst: filter_second_element.average(:firstvalue).to_f.round(2),
				allsecond: filter_second_element.average(:secondvalue).to_f.round(2),
				allfull: filter_second_element.average(:totalvalue).to_f.round(2),
				allcount: filter_second_element.count(:totalvalue).to_i
			}
			if index < 2 || index > 13
				result_element[:full_first] = (filter_second_element.average(:roadthird).to_f + filter_second_element.average(:roadforth).to_f + filter_second_element.average(:roadfirsthalf).to_f).round(2)
				result_element[:full_second] = (filter_second_element.average(:homethird).to_f + filter_second_element.average(:homeforth).to_f + filter_second_element.average(:homefirsthalf).to_f).round(2)
				result_element[:firsthalf_first] = filter_second_element.average(:roadfirsthalf).to_f.round(2)
				result_element[:firsthalf_second] = filter_second_element.average(:homefirsthalf).to_f.round(2)
				result_element[:secondhalf_first] = (filter_second_element.average(:roadthird).to_f.round(2) + filter_second_element.average(:roadforth).to_f.round(2)).round(2)
				result_element[:secondhalf_second] = (filter_second_element.average(:homethird).to_f.round(2) + filter_second_element.average(:homeforth).to_f.round(2)).round(2)
			end
			@filterResult.push(result_element)
		end
		@home_team_info = Team.find_by(abbr: @home_abbr)
    	@away_team_info = Team.find_by(abbr: @away_abbr)
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
		@countItem = Fullseason.where("awaylastfly = ? AND awaynextfly = ? AND roadlast = ? AND roadnext = ? AND homenext = ? AND homelast = ? AND homenextfly = ? AND homelastfly = ?", @game.away_last_fly, @game.away_next_fly, @game.away_last_game, @game.away_next_game, @game.home_next_game, @game.home_last_game, @game.home_next_fly, @game.home_last_fly)
		

		@compares = @game.compares.all
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
