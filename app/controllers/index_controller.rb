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
		@result = Refereestatic.all
	end

	def detail
		@match = {
	  		'GS' => 'GSW',
	  		'NY' => 'NYK',
	  		'PHX' => 'PHO',
	  		'SA' => 'SAS',
	  		'UTAH' => 'UTA',
	  		'WSH' => 'WAS',
	  		'NO' => 'NOP'
	  	}
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

		@away_last = Nba.where("home_abbr = ? AND game_date < ? AND total_point != 0", @away_abbr, @now).or(Nba.where("away_abbr = ? AND game_date < ? AND total_point != 0", @away_abbr, @now)).order(:game_date).last
		@home_last = Nba.where("home_abbr = ? AND game_date < ? AND total_point != 0", @home_abbr, @now).or(Nba.where("away_abbr = ? AND game_date < ? AND total_point != 0", @home_abbr, @now)).order(:game_date).last
		
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

		@away_players_search = @away_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @away_flag).order(:state)
		@away_players = @away_players_search.to_a
		@away_players_group1 = []
		@away_players_group2 = []
		@away_players_group3 = @away_players.dup
		@away_starter_abbr = @away_abbr
		@away_starter_abbr = @match[@away_starter_abbr] if @match[@away_starter_abbr]
		@away_starters = Starter.where('team = ? AND time = ?', @away_starter_abbr, DateTime.parse(@game.game_date).strftime("%FT%T+00:00")).order(:index)
		@away_starters.each do |away_starter|
			away_starter_player_name = away_starter.player_name
			away_starter_player_fullname = away_starter_player_name.gsub('.', '')
			selected_player = @away_players_search.where("player_fullname = ?", away_starter_player_fullname).first
			selected_player = @away_players_search.where("player_name = ?", away_starter_player_name).first unless selected_player
			if away_starter_player_name == 'J.R. Smith'
				selected_player = @away_players_search.where("link = 'http://www.espn.com/nba/player/_/id/2444/jr-smith'").first
			elsif away_starter_player_name == 'Taurean Prince'
				selected_player = @away_players_search.where("player_fullname = 'Taurean Waller-Prince'").first
			end
			if selected_player
				selected_player.position = away_starter.position
				@away_players_group3.delete(selected_player)
				if away_starter.position == 'PG' || away_starter.position == 'SG'
					@away_players_group1.push(selected_player)
				else
					@away_players_group2.push(selected_player)
				end
			else
				additional_player = Player.where("player_fullname = ? AND game_date < ?", away_starter_player_fullname, @now).order(:game_date).last
				additional_player = Player.where("player_name = ? AND game_date < ?", away_starter_player_name, @now).order(:game_date).last unless additional_player
				if away_starter_player_name == 'J.R. Smith'
					additional_player = Player.where("link = 'http://www.espn.com/nba/player/_/id/2444/jr-smith' AND game_date < ?", @now).order(:game_date).last
				elsif away_starter_player_name == 'Taurean Prince'
					additional_player = Player.where("player_fullname = 'Taurean Waller-Prince' AND game_date < ?", @now).order(:game_date).last
				end
				if additional_player
					additional_player.position = away_starter.position
					@away_players.push(additional_player)
					if away_starter.position == 'PG' || away_starter.position == 'SG'
						@away_players_group1.push(additional_player)
					else
						@away_players_group2.push(additional_player)
					end
				end
			end
		end

		@home_players_search = @home_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @home_flag).order(:state)
		@home_players = @home_players_search.to_a
		@home_players_group1 = []
		@home_players_group2 = []
		@home_players_group3 = @home_players.dup
		@home_starter_abbr = @home_abbr
		@home_starter_abbr = @match[@home_starter_abbr] if @match[@home_starter_abbr]
		@home_starters = Starter.where('team = ? AND time = ?', @home_starter_abbr, DateTime.parse(@game.game_date).strftime("%FT%T+00:00")).order(:index)
		@home_starters.each do |home_starter|
			home_starter_player_name = home_starter.player_name
			home_starter_player_fullname = home_starter_player_name.gsub('.', '')
			selected_player = @home_players_search.where("player_fullname = ?", home_starter_player_fullname).first
			selected_player = @home_players_search.where("player_name = ?", home_starter_player_name).first unless selected_player
			if home_starter_player_name == 'J.R. Smith'
				selected_player = @home_players_search.where("link = 'http://www.espn.com/nba/player/_/id/2444/jr-smith'").first
			elsif home_starter_player_name == 'Taurean Prince'
				selected_player = @home_players_search.where("player_fullname = 'Taurean Waller-Prince'").first
			end

			if selected_player
				selected_player.position = home_starter.position
				@home_players_group3.delete(selected_player)
				if home_starter.position == 'PG' || home_starter.position == 'SG'
					@home_players_group1.push(selected_player)
				else
					@home_players_group2.push(selected_player)
				end
			else
				additional_player = Player.where("player_fullname = ? AND game_date < ?", home_starter_player_fullname, @now).order(:game_date).last
				additional_player = Player.where("player_name = ? AND game_date < ?", home_starter_player_name, @now).order(:game_date).last unless additional_player
				if home_starter_player_name == 'J.R. Smith'
					additional_player = Player.where("link = 'http://www.espn.com/nba/player/_/id/2444/jr-smith' AND game_date < ?", @now).order(:game_date).last
				elsif home_starter_player_name == 'Taurean Prince'
					additional_player = Player.where("player_fullname = 'Taurean Waller-Prince' AND game_date < ?", @now).order(:game_date).last
				end
				if additional_player
					additional_player.position = home_starter.position
					@home_players.push(additional_player)
					if home_starter.position == 'PG' || home_starter.position == 'SG'
						@home_players_group1.push(additional_player)
					else
						@home_players_group2.push(additional_player)
					end
				end
			end
		end

		@home_injury = Injury.where("team = ? AND today = ?", @game.home_team, Date.parse(@game.game_date))
		@home_injury = Injury.where("team = ? AND today = ?", @game.home_team, Date.parse(@game.game_date) - 1.day) unless @home_injury.size
		@away_injury = Injury.where("team = ? AND today = ?", @game.away_team, Date.parse(@game.game_date))
		@away_injury = Injury.where("team = ? AND today = ?", @game.away_team, Date.parse(@game.game_date) - 1.day) unless @away_injury.size

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
        @injury_away_total_pf = 0
        @injury_away_total_or = 0
        @injury_away_total_to = 0
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_away_total_min = @injury_away_total_min + player.sum_mins/(count - 2)
	        @injury_away_total_stl = @injury_away_total_stl + player.sum_stl.to_f/count
	        @injury_away_total_blk = @injury_away_total_blk + player.sum_blk.to_f/count
	        @injury_away_total_to = @injury_away_total_to + player.sum_to.to_f/count
	        @injury_away_total_pf = @injury_away_total_pf + player.sum_pf.to_i/count
	        @injury_away_total_or = @injury_away_total_or + player.sum_or.to_f/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_away_drtg_one = @injury_away_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @injury_away_drtg_one_container.push(player.id)
	        @injury_away_total_poss = @injury_away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    if injury_drtg_count < 3
	    	@away_players_group4 = @away_players_group3.select {|element| element.position == 'PG' || element.position == 'SG'}
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_away_total_min = @injury_away_total_min + player.sum_mins/(count - 2)
	        @injury_away_total_stl = @injury_away_total_stl + player.sum_stl.to_f/count
	        @injury_away_total_blk = @injury_away_total_blk + player.sum_blk.to_f/count
	        @injury_away_total_to = @injury_away_total_to + player.sum_to.to_f/count
	        @injury_away_total_pf = @injury_away_total_pf + player.sum_pf.to_i/count
	        @injury_away_total_or = @injury_away_total_or + player.sum_or.to_f/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_away_drtg_two = @injury_away_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @injury_away_drtg_two_container.push(player.id)
	        @injury_away_total_poss = @injury_away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    if injury_drtg_count < 3
	    	@away_players_group4 = @away_players_group3.select {|element| element.position == 'C' || element.position == 'SF' || element.position == 'PF' }
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        @injury_away_total_min = @injury_away_total_min + player.sum_mins/(count - 2)
	        @injury_away_total_stl = @injury_away_total_stl + player.sum_stl.to_f/count
	        @injury_away_total_blk = @injury_away_total_blk + player.sum_blk.to_f/count
	        @injury_away_total_to = @injury_away_total_to + player.sum_to.to_f/count
	        @injury_away_total_pf = @injury_away_total_pf + player.sum_pf.to_i/count
	        @injury_away_total_or = @injury_away_total_or + player.sum_or.to_f/count
	        @injury_away_total_poss = @injury_away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    @injury_home_total_poss = 0
	    @injury_home_total_min = 0
        @injury_home_total_stl = 0
        @injury_home_total_to = 0
        @injury_home_total_blk = 0
        @injury_home_total_pf = 0
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_home_total_min = @injury_home_total_min + player.sum_mins/(count - 2)
	        @injury_home_total_stl = @injury_home_total_stl + player.sum_stl.to_f/count
	        @injury_home_total_to = @injury_home_total_to + player.sum_to.to_f/count
	        @injury_home_total_blk = @injury_home_total_blk + player.sum_blk.to_f/count
	        @injury_home_total_pf = @injury_home_total_pf + player.sum_pf.to_i/count
	        @injury_home_total_or = @injury_home_total_or + player.sum_or.to_f/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_home_drtg_one = @injury_home_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @injury_home_total_poss = @injury_home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @injury_home_drtg_one_container.push(player.id)
	    end
	    if injury_drtg_count < 3
	    	@home_players_group4 = @home_players_group3.select {|element| element.position == 'PG' || element.position == 'SG'}
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_home_total_min = @injury_home_total_min + player.sum_mins/(count - 2)
	        @injury_home_total_stl = @injury_home_total_stl + player.sum_stl.to_f/count
	        @injury_home_total_to = @injury_home_total_to + player.sum_to.to_f/count
	        @injury_home_total_blk = @injury_home_total_blk + player.sum_blk.to_f/count
	        @injury_home_total_pf = @injury_home_total_pf + player.sum_pf.to_i/count
	        @injury_home_total_or = @injury_home_total_or + player.sum_or.to_f/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_home_drtg_two = @injury_home_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @injury_home_total_poss = @injury_home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @injury_home_drtg_two_container.push(player.id)
	    end
	    if injury_drtg_count < 3
	    	@home_players_group4 = @home_players_group3.select {|element| element.position == 'C' || element.position == 'SF' || element.position == 'PF'}
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        @injury_home_total_min = @injury_home_total_min + player.sum_mins/(count - 2)
	        @injury_home_total_stl = @injury_home_total_stl + player.sum_stl.to_f/count
	        @injury_home_total_to = @injury_home_total_to + player.sum_to.to_f/count
	        @injury_home_total_blk = @injury_home_total_blk + player.sum_blk.to_f/count
	        @injury_home_total_pf = @injury_home_total_pf + player.sum_pf.to_i/count
	        @injury_home_total_or = @injury_home_total_or + player.sum_or.to_f/count
	        @injury_home_total_poss = @injury_home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    @away_total_poss = 0
	    @away_total_min = 0
        @away_total_stl = 0
        @away_total_to = 0
        @away_total_blk = 0
        @away_total_pf = 0
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        drtg_count = drtg_count + 1
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        @away_total_stl = @away_total_stl + player.sum_stl.to_f/count
	        @away_total_to = @away_total_to + player.sum_to.to_f/count
	        @away_total_blk = @away_total_blk + player.sum_blk.to_f/count
	        @away_total_pf = @away_total_pf + player.sum_pf.to_i/count
	        @away_total_or = @away_total_or + player.sum_or.to_f/count
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @away_drtg_one = @away_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @away_drtg_one_container.push(player.id)
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    if drtg_count < 3
	    	@away_players_group4 = @away_players_group3.select {|element| element.position == 'PG' || element.position == 'SG' }
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        drtg_count = drtg_count + 1
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        @away_total_stl = @away_total_stl + player.sum_stl.to_f/count
	        @away_total_to = @away_total_to + player.sum_to.to_f/count
	        @away_total_blk = @away_total_blk + player.sum_blk.to_f/count
	        @away_total_pf = @away_total_pf + player.sum_pf.to_i/count
	        @away_total_or = @away_total_or + player.sum_or.to_f/count
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @away_drtg_two = @away_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @away_drtg_two_container.push(player.id)
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    if drtg_count < 3
	    	@away_players_group4 = @away_players_group3.select {|element| element.position == 'C' || element.position == 'SF' || element.position == 'PF' }
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        @away_total_stl = @away_total_stl + player.sum_stl.to_f/count
	        @away_total_to = @away_total_to + player.sum_to.to_f/count
	        @away_total_blk = @away_total_blk + player.sum_blk.to_f/count
	        @away_total_pf = @away_total_pf + player.sum_pf.to_i/count
	        @away_total_or = @away_total_or + player.sum_or.to_f/count
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    @home_total_poss = 0
	    @home_total_min = 0
        @home_total_stl = 0
        @home_total_to = 0
        @home_total_blk = 0
        @home_total_pf = 0
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        drtg_count = drtg_count + 1
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        @home_total_stl = @home_total_stl + player.sum_stl.to_f/count
	        @home_total_to = @home_total_to + player.sum_to.to_f/count
	        @home_total_blk = @home_total_blk + player.sum_blk.to_f/count
	        @home_total_pf = @home_total_pf + player.sum_pf.to_i/count
	        @home_total_or = @home_total_or + player.sum_or.to_f/count
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @home_drtg_one = @home_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @home_drtg_one_container.push(player.id)
	    end
	    if drtg_count < 3
	    	@home_players_group4 = @home_players_group3.select {|element| element.position == 'PG' || element.position == 'SG'}
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        drtg_count = drtg_count + 1
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        @home_total_stl = @home_total_stl + player.sum_stl.to_f/count
	        @home_total_to = @home_total_to + player.sum_to.to_f/count
	        @home_total_blk = @home_total_blk + player.sum_blk.to_f/count
	        @home_total_pf = @home_total_pf + player.sum_pf.to_i/count
	        @home_total_or = @home_total_or + player.sum_or.to_f/count
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @home_drtg_two = @home_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @home_drtg_two_container.push(player.id)
	    end
	    if drtg_count < 3
	    	@home_players_group4 = @home_players_group3.select {|element| element.position == 'C' || element.position == 'SF' || element.position == 'PF'}
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        @home_total_stl = @home_total_stl + player.sum_stl.to_f/count
	        @home_total_to = @home_total_to + player.sum_to.to_f/count
	        @home_total_blk = @home_total_blk + player.sum_blk.to_f/count
	        @home_total_pf = @home_total_pf + player.sum_pf.to_i/count
	        @home_total_or = @home_total_or + player.sum_or.to_f/count
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
	    	[false, true, false, true, true, false, true, false],
	    	[true, true, false, false, false, false, true, true]
		]
		@break = [9, 15, 16]
		@filterResult = []
		@filterResult_secondtravel = []
		@filters.each_with_index do |filter, index|
			search_string = []
			search_second_string = []
			if @game.away_last_fly != nil
				if filter[0]
					search_string.push("awaylastfly = '#{@game.away_last_fly}'")
					search_second_string.push("awaylastfly = '#{@game.away_last_fly}'")
					filter[0] = @game.away_last_fly[0]
				else
					search_string.push("awaylastfly <> '#{@game.away_last_fly}'")
				end
			end
			if @game.away_next_fly != nil
				if filter[1]
					search_string.push("awaynextfly = '#{@game.away_next_fly}'")
					search_second_string.push("awaynextfly = '#{@game.away_next_fly}'")
					filter[1] = @game.away_next_fly[0]
				else
					search_string.push("awaynextfly <> '#{@game.away_next_fly}'")
				end
			end
			if @game.away_last_game
				if filter[2]
					search_string.push("roadlast = '#{@game.away_last_game}'")
					search_second_string.push("roadlast = '#{@game.away_last_game}'")
					filter[2] = @game.away_last_game
				else
					search_string.push("roadlast <> '#{@game.away_last_game}'")
				end
			end
			if @game.away_next_game
				if filter[3]
					search_string.push("roadnext = '#{@game.away_next_game}'")
					search_second_string.push("roadnext = '#{@game.away_next_game}'")
					filter[3] = @game.away_next_game
				else
					search_string.push("roadnext <> '#{@game.away_next_game}'")
				end
			end
			if @game.home_next_game
				if filter[4]
					search_string.push("homenext = '#{@game.home_next_game}'")
					search_second_string.push("homenext = '#{@game.home_next_game}'")
					filter[4] = @game.home_next_game
				else
					search_string.push("homenext <> '#{@game.home_next_game}'")
				end
			end
			if @game.home_last_game
				if filter[5]
					search_string.push("homelast = '#{@game.home_last_game}'")
					search_second_string.push("homelast = '#{@game.home_last_game}'")
					filter[5] = @game.home_last_game
				else
					search_string.push("homelast <> '#{@game.home_last_game}'")
				end
			end
			if @game.home_next_fly
				if filter[6]
					search_string.push("homenextfly = '#{@game.home_next_fly}'")
					search_second_string.push("homenextfly = '#{@game.home_next_fly}'")
					filter[6] = @game.home_next_fly[0]
				else
					search_string.push("homenextfly <> '#{@game.home_next_fly}'")
				end
			end
			if @game.home_last_fly
				if filter[7]
					search_string.push("homelastfly = '#{@game.home_last_fly}'")
					search_second_string.push("homelastfly = '#{@game.home_last_fly}'")
					filter[7] = @game.home_last_fly[0]
				else
					search_string.push("homelastfly <> '#{@game.home_last_fly}'")
				end
			end
			search_string = search_string.join(" AND ")
			search_second_string = search_second_string.join(" AND ")
			filter_element = Fullseason.where(search_string).to_a
			filter_second_element = Fullseason.where(search_second_string).to_a
			filter_second_element_side = Fullseason.where(search_second_string)
			temp_count1 = filter_element.count
			result_element = {
				first: (filter_element.map {|stat| stat.firstvalue.to_f }.sum / (temp_count1 == 0 ? 1 : temp_count1)).round(2),
				second: (filter_element.map {|stat| stat.secondvalue.to_f }.sum / (temp_count1 == 0 ? 1 : temp_count1)).round(2),
				full: (filter_element.map {|stat| stat.totalvalue.to_f }.sum / (temp_count1 == 0 ? 1 : temp_count1)).round(2),
				count: temp_count1,
				first_half_away: filter_second_element_side.where("first_half_bigger = 'AWAY'").count,
				first_half_home: filter_second_element_side.where("first_half_bigger = 'HOME'").count,
				second_half_away: filter_second_element_side.where("second_half_bigger = 'AWAY'").count,
				second_half_home: filter_second_element_side.where("second_half_bigger = 'HOME'").count
			}
			if index != 0
				temp_count3 = filter_second_element.count
				result_element[:allfirst] = (filter_second_element.map {|stat| stat.firstvalue.to_f }.sum / (temp_count3 == 0 ? 1 : temp_count3)).round(2)
				result_element[:allsecond] = (filter_second_element.map {|stat| stat.secondvalue.to_f }.sum / (temp_count3 == 0 ? 1 : temp_count3)).round(2)
				result_element[:allfull] = (filter_second_element.map {|stat| stat.totalvalue.to_f }.sum / (temp_count3 == 0 ? 1 : temp_count3)).round(2)
				result_element[:allcount] = temp_count3
				result_element[:home_ortg] = (filter_second_element.map {|stat| stat.home_ortg.to_f }.sum / (temp_count3 == 0 ? 1 : temp_count3)).round(2)
				result_element[:away_ortg] = (filter_second_element.map {|stat| stat.away_ortg.to_f }.sum / (temp_count3 == 0 ? 1 : temp_count3)).round(2)
				result_element[:first_under] = filter_second_element_side.where("firstou = 'under'").count
				result_element[:first_over] = filter_second_element_side.where("firstou = 'over'").count
				result_element[:second_under] = filter_second_element_side.where("secondou = 'under'").count
				result_element[:second_over] = filter_second_element_side.where("secondou = 'over'").count
				if index == 1 || index == 2 || index > 9
					result_element[:firsthalf_first] = (filter_second_element.map {|stat| stat.roadfirsthalf.to_f }.sum / (temp_count3 == 0 ? 1 : temp_count3)).round(2)
					result_element[:firsthalf_second] = (filter_second_element.map {|stat| stat.homefirsthalf.to_f }.sum / (temp_count3 == 0 ? 1 : temp_count3)).round(2)
					result_element[:secondhalf_first] = (filter_second_element.map {|stat| stat.roadthird.to_f + stat.roadforth.to_f }.sum / (temp_count3 == 0 ? 1 : temp_count3)).round(2)
					result_element[:secondhalf_second] = (filter_second_element.map {|stat| stat.homethird.to_f + stat.homeforth.to_f }.sum / (temp_count3 == 0 ? 1 : temp_count3)).round(2)
					result_element[:full_first] = (result_element[:secondhalf_first] + result_element[:firsthalf_first]).round(2)
					result_element[:full_second] = (result_element[:secondhalf_second] + result_element[:firsthalf_second]).round(2)
					result_element[:bj] = filter_second_element_side.average(:fgside).to_f.round(2)
					result_element[:bg] = filter_second_element_side.average(:firstside).to_f.round(2)
					result_element[:bh] = filter_second_element_side.average(:secondside).to_f.round(2)
					filter_second_element_again = Fullseason.where(search_second_string).where("firstlinetotal is not null AND firstlinetotal != 0")
					result_element[:bi_one] = (filter_second_element_again.average(:roadfirsthalf).to_f - filter_second_element_again.average(:homefirsthalf).to_f).round(2)
					result_element[:bi_two] = (filter_second_element_again.average(:roadthird).to_f + filter_second_element_again.average(:roadforth).to_f - filter_second_element_again.average(:homethird).to_f - filter_second_element_again.average(:homeforth).to_f).round(2)
					result_element[:bi_count] = filter_second_element_again.count(:firstlinetotal).to_i
				end
			else
				result_element[:allfirst] = 99.09
				result_element[:allsecond] = 97.01
				result_element[:allfull] = 196.11
				result_element[:allcount] = 20904
				result_element[:home_ortg] = 108.47
				result_element[:away_ortg] = 105.15
				result_element[:bj] = -3.21
				result_element[:bg] = -1.75
				result_element[:bh] = -1.26
				result_element[:firsthalf_first] = 48.62
				result_element[:firsthalf_second] = 50.47
				result_element[:secondhalf_first] = 47.91
				result_element[:secondhalf_second] = 49.1
				result_element[:full_first] = (result_element[:secondhalf_first] + result_element[:firsthalf_first]).round(2)
				result_element[:full_second] = (result_element[:secondhalf_second] + result_element[:firsthalf_second]).round(2)
				result_element[:bi_one] = -1.7
				result_element[:bi_two] = -1.07
				result_element[:bi_count] = 9328
			end

			filter_element_secondtravel = Secondtravel.where(search_string).to_a
			temp_count2 = filter_element_secondtravel.count
			result_element_secondtravel = {
				first: (filter_element_secondtravel.map {|stat| stat.firstvalue.to_f }.sum / (temp_count2 == 0 ? 1 : temp_count2)).round(2),
				second: (filter_element_secondtravel.map {|stat| stat.secondvalue.to_f }.sum / (temp_count2 == 0 ? 1 : temp_count2)).round(2),
				full: (filter_element_secondtravel.map {|stat| stat.totalvalue.to_f }.sum / (temp_count2 == 0 ? 1 : temp_count2)).round(2),
				count: temp_count2
			}
			if index != 0
				filter_second_element_secondtravel = Secondtravel.where(search_second_string).to_a
				temp_count4 = filter_second_element_secondtravel.count
				result_element_secondtravel[:allfirst] = (filter_second_element_secondtravel.map {|stat| stat.firstvalue.to_f }.sum / (temp_count4 == 0 ? 1 : temp_count4)).round(2)
				result_element_secondtravel[:allsecond] = (filter_second_element_secondtravel.map {|stat| stat.secondvalue.to_f }.sum / (temp_count4 == 0 ? 1 : temp_count4)).round(2)
				result_element_secondtravel[:allfull] = (filter_second_element_secondtravel.map {|stat| stat.totalvalue.to_f }.sum / (temp_count4 == 0 ? 1 : temp_count4)).round(2)
				result_element_secondtravel[:allcount] = temp_count4
				if index == 1 || index == 2 || index > 9
					result_element_secondtravel[:firsthalf_first] = (filter_second_element_secondtravel.map {|stat| stat.roadfirsthalf.to_f }.sum / (temp_count4 == 0 ? 1 : temp_count4)).round(2)
					result_element_secondtravel[:firsthalf_second] = (filter_second_element_secondtravel.map {|stat| stat.homefirsthalf.to_f }.sum / (temp_count4 == 0 ? 1 : temp_count4)).round(2)
					result_element_secondtravel[:secondhalf_first] = (filter_second_element_secondtravel.map {|stat| stat.roadthird.to_f + stat.roadforth.to_f }.sum / (temp_count4 == 0 ? 1 : temp_count4)).round(2)
					result_element_secondtravel[:secondhalf_second] = (filter_second_element_secondtravel.map {|stat| stat.homethird.to_f + stat.homeforth.to_f }.sum / (temp_count4 == 0 ? 1 : temp_count4)).round(2)
					result_element_secondtravel[:full_first] = (result_element_secondtravel[:firsthalf_first] + result_element_secondtravel[:secondhalf_first]).round(2)
					result_element_secondtravel[:full_second] = (result_element_secondtravel[:firsthalf_second] + result_element_secondtravel[:secondhalf_second]).round(2)
					result_element_secondtravel[:bj] = Secondtravel.where(search_second_string).average(:fgside).to_f.round(2)
				end
			else
				result_element_secondtravel[:allfirst] = 99.0
				result_element_secondtravel[:allsecond] = 97.01
				result_element_secondtravel[:allfull] = 196.0
				result_element_secondtravel[:allcount] = 11380
				result_element_secondtravel[:bj] = -3.61
				result_element_secondtravel[:firsthalf_first] = 48.75
				result_element_secondtravel[:firsthalf_second] = 50.98
				result_element_secondtravel[:secondhalf_first] = 48.84
				result_element_secondtravel[:secondhalf_second] = 50.15
				result_element_secondtravel[:full_first] = (result_element_secondtravel[:firsthalf_first] + result_element_secondtravel[:secondhalf_first]).round(2)
				result_element_secondtravel[:full_second] = (result_element_secondtravel[:firsthalf_second] + result_element_secondtravel[:secondhalf_second]).round(2)
			end
			@filterResult.push(result_element)
			@filterResult_secondtravel.push(result_element_secondtravel)
		end
		@home_team_info = @game.team_stats.find_by(abbr: @home_abbr)
		@home_team_info = Team.find_by(abbr: @home_abbr) unless @home_team_info
    	@away_team_info = @game.team_stats.find_by(abbr: @away_abbr)
		@away_team_info = Team.find_by(abbr: @away_abbr) unless @away_team_info
    	@away_last_games = Nba.where("home_team = ? AND game_date < ?", @game.away_team, @game.game_date).or(Nba.where("away_team = ? AND game_date < ?", @game.away_team, @game.game_date)).order(game_date: :desc).limit(12)
    	@away_stl = 0
	    @away_blk = 0
	    @away_or = 0
	    @away_to = 0
	    @away_last_games.each do |last_game|
	        if last_game.home_team == @game.away_team
	        	@away_stl = @away_stl + last_game.home_stl.to_i
	         	@away_blk = @away_blk + last_game.home_blk.to_i
	        	@away_or = @away_or + last_game.home_orValue.to_i
	         	@away_to = @away_to + last_game.home_toValue.to_i
	        else
	          	@away_stl = @away_stl + last_game.away_stl.to_i
	          	@away_blk = @away_blk + last_game.away_blk.to_i
	        	@away_or = @away_or + last_game.away_orValue.to_i
	         	@away_to = @away_to + last_game.away_toValue.to_i
	        end
	    end
	    @away_count = @away_last_games.count
	    if @away_count
	    	@away_stl = (@away_stl.to_f / @away_count).round(2)
	        @away_blk = (@away_blk.to_f / @away_count).round(2)
	        @away_or = (@away_or.to_f / @away_count).round(2)
	        @away_to = (@away_to.to_f / @away_count).round(2)
	    end

    	@home_last_games = Nba.where("home_team = ? AND game_date < ?", @game.home_team, @game.game_date).or(Nba.where("away_team = ? AND game_date < ?", @game.home_team, @game.game_date)).order(game_date: :desc).limit(12)
    	@home_stl = 0
	    @home_blk = 0
	    @home_or = 0
	    @home_to = 0

      	@home_last_games.each do |last_game|
	        if last_game.home_team == @game.home_team
	        	@home_stl = @home_stl + last_game.home_stl.to_i
	          	@home_blk = @home_blk + last_game.home_blk.to_i
	        	@home_or = @home_or + last_game.home_orValue.to_i
	         	@home_to = @home_to + last_game.home_toValue.to_i
	        else
	          	@home_stl = @home_stl + last_game.away_stl.to_i
	          	@home_blk = @home_blk + last_game.away_blk.to_i
	        	@home_or = @home_or + last_game.away_orValue.to_i
	         	@home_to = @home_to + last_game.away_toValue.to_i
	        end
	    end
	    @home_count = @home_last_games.count
	    if @home_count
	        @home_stl = (@home_stl.to_f / @home_count).round(2)
	        @home_blk = (@home_blk.to_f / @home_count).round(2)
	        @home_or = (@home_or.to_f / @home_count).round(2)
	        @home_to = (@home_to.to_f / @home_count).round(2)
	    end

	    @away_players_starters = @away_players_group1 + @away_players_group2
	    @home_players_starters = @home_players_group1 + @home_players_group2

	    @away_avg_stl = 0
	    @away_avg_blk = 0
	    @away_avg_or = 0
	    @away_avg_to = 0
	    @away_players_starters.each do |player|
	    	last_players = Player.where("player_name = ? AND mins <> 0", player.player_name).order(game_date: :desc).limit(12)
	    	average_mins = 0
	    	average_stl = 0
	    	average_blk = 0
	    	average_or = 0
	    	average_to = 0
	    	last_players_count = last_players.count
	    	last_players.each do |last_player|
	    		average_mins = average_mins + last_player.mins
	    		average_stl = average_stl + last_player.stlValue
	    		average_blk = average_blk + last_player.blkValue
	    		average_or = average_or + last_player.orValue
	    		average_to = average_to + last_player.toValue
	    	end
	    	average_mins = average_mins.to_f / last_players_count
	    	average_stl = average_stl.to_f / last_players_count
	    	average_blk = average_blk.to_f / last_players_count
	    	average_or = average_or.to_f / last_players_count
	    	average_to = average_to.to_f / last_players_count
	    	@away_avg_stl = @away_avg_stl + 48 / average_mins * average_stl
	    	@away_avg_blk = @away_avg_blk + 48 / average_mins * average_blk
	    	@away_avg_or = @away_avg_or + 48 / average_mins * average_or
	    	@away_avg_to = @away_avg_to + 48 / average_mins * average_to
	    end

	    @home_avg_stl = 0
	    @home_avg_blk = 0
	    @home_avg_or = 0
	    @home_avg_to = 0
	    @home_players_starters.each do |player|
	    	last_players = Player.where("player_name = ? AND mins <> 0", player.player_name).order(game_date: :desc).limit(12)
	    	average_mins = 0
	    	average_stl = 0
	    	average_blk = 0
	    	average_or = 0
	    	average_to = 0
	    	last_players_count = last_players.count
	    	last_players.each do |last_player|
	    		average_mins = average_mins + last_player.mins
	    		average_stl = average_stl + last_player.stlValue
	    		average_blk = average_blk + last_player.blkValue
	    		average_or = average_or + last_player.orValue
	    		average_to = average_to + last_player.toValue
	    	end
	    	average_mins = average_mins.to_f / last_players_count
	    	average_stl = average_stl.to_f / last_players_count
	    	average_blk = average_blk.to_f / last_players_count
	    	average_or = average_or.to_f / last_players_count
	    	average_to = average_to.to_f / last_players_count
	    	@home_avg_stl = @home_avg_stl + 48 / average_mins * average_stl
	    	@home_avg_blk = @home_avg_blk + 48 / average_mins * average_blk
	    	@home_avg_or = @home_avg_or + 48 / average_mins * average_or
	    	@home_avg_to = @home_avg_to + 48 / average_mins * average_to
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
		
		secondItem_secondtravel = Secondtravel.where(hometeam: @game.home_team)
		thirdItem_secondtravel = Secondtravel.where(week: @game.week)
		@firstItem_result_secondtravel = {
			first: '',
			second: '',
			full: '',
			count: ''
		}
		@secondItem_result_secondtravel = {
			first: secondItem_secondtravel.average(:firstpoint).to_f.round(2),
			second: secondItem_secondtravel.average(:secondpoint).to_f.round(2),
			full: secondItem_secondtravel.average(:totalpoint).to_f.round(2),
			count: secondItem_secondtravel.count(:totalpoint).to_i
		}
		@thirdItem_result_secondtravel = {
			first: thirdItem_secondtravel.average(:firstpoint).to_f.round(2),
			second: thirdItem_secondtravel.average(:secondpoint).to_f.round(2),
			full: thirdItem_secondtravel.average(:totalpoint).to_f.round(2),
			count: thirdItem_secondtravel.count(:totalpoint).to_i
		}

		@countItem = Fullseason.where("awaylastfly = ? AND awaynextfly = ? AND roadlast = ? AND roadnext = ? AND homenext = ? AND homelast = ? AND homenextfly = ? AND homelastfly = ?", @game.away_last_fly, @game.away_next_fly, @game.away_last_game, @game.away_next_game, @game.home_next_game, @game.home_last_game, @game.home_next_fly, @game.home_last_fly)
 		@secondItem = Secondtravel.where("awaylastfly = ? AND awaynextfly = ? AND roadlast = ? AND roadnext = ? AND homenext = ? AND homelast = ? AND homenextfly = ? AND homelastfly = ?", @game.away_last_fly, @game.away_next_fly, @game.away_last_game, @game.away_next_game, @game.home_next_game, @game.home_last_game, @game.home_next_fly, @game.home_last_fly)
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
		referee_one_last = 200 if referee_one_last == nil
		referee_two_last = 200 if referee_two_last == nil
		referee_three_last = 200 if referee_three_last == nil
		if referee_one_last == referee_two_last && referee_two_last == referee_three_last
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

		referee_one_next = 200 if referee_one_next == nil
		referee_two_next = 200 if referee_two_next == nil
		referee_three_next = 200 if referee_three_next == nil

		if referee_one_next == referee_two_next && referee_two_next == referee_three_next
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
					if referee_filter_element[0] > 8
						search_array.push("referee_one_last > 8")
					elsif referee_filter_element[0] > 5
						search_array.push("referee_one_last > 5 AND referee_one_last < 9")
					else
						search_array.push("referee_one_last = #{referee_filter_element[0]}")
					end
					if referee_filter_element[1] > 8
						search_array.push("referee_two_last > 8")
					elsif referee_filter_element[1] > 5
						search_array.push("referee_two_last > 5 AND referee_two_last < 9")
					else
						search_array.push("referee_two_last = #{referee_filter_element[1]}")
					end
					if referee_filter_element[2] > 8
						search_array.push("referee_three_last > 8")
					elsif referee_filter_element[2] > 5
						search_array.push("referee_three_last > 5 AND referee_three_last < 9")
					else
						search_array.push("referee_three_last = #{referee_filter_element[2]}")
					end
				else
					if referee_filter_element[0] > 8
						search_array.push("referee_one_next > 8")
					elsif referee_filter_element[0] > 5
						search_array.push("referee_one_next > 5 AND referee_one_next < 9")
					else
						search_array.push("referee_one_next = #{referee_filter_element[0]}")
					end
					if referee_filter_element[1] > 8
						search_array.push("referee_two_next > 8")
					elsif referee_filter_element[1] > 5
						search_array.push("referee_two_next > 5 AND referee_two_next < 9")
					else
						search_array.push("referee_two_next = #{referee_filter_element[1]}")
					end
					if referee_filter_element[2] > 8
						search_array.push("referee_three_next > 8")
					elsif referee_filter_element[2] > 5
						search_array.push("referee_three_next > 5 AND referee_three_next < 9")
					else
						search_array.push("referee_three_next = #{referee_filter_element[2]}")
					end
				end
				search_array = search_array.join(" AND ")
				referee_filter_result = Referee.where(search_array)
				@referee_filter_results.push([
					referee_filter_result.average(:tp_1h).to_f.round(2),
					referee_filter_result.average(:tp_2h).to_f.round(2),
					(referee_filter_result.average(:away_pf).to_f.round(2) + referee_filter_result.average(:home_pf).to_f.round(2)).round(2),
					(referee_filter_result.average(:away_fta).to_f.round(2) + referee_filter_result.average(:home_fta).to_f.round(2)).round(2),
					referee_filter_result.count(:tp_1h).to_i
				])
			else
				@referee_filter_results.push(['-', '-',	'-', '-', '-'])
			end
		end

		if referee_one_last > referee_two_last
			temp = referee_one_last
			referee_one_last = referee_two_last
			referee_two_last = temp
		end

		if referee_one_last > referee_three_last
			temp = referee_one_last
			referee_one_last = referee_three_last
			referee_three_last = temp
		end

		if referee_two_last > referee_three_last
			temp = referee_two_last
			referee_two_last = referee_three_last
			referee_three_last = temp
		end

		if referee_one_last > 8
			referee_one_last = "9+"
		elsif referee_one_last > 5
			referee_one_last = "6-8"
		else
			referee_one_last = referee_one_last.to_s
		end

		if referee_two_last > 8
			referee_two_last = "9+"
		elsif referee_two_last > 5
			referee_two_last = "6-8"
		else
			referee_two_last = referee_two_last.to_s
		end

		if referee_three_last > 8
			referee_three_last = "9+"
		elsif referee_three_last > 5
			referee_three_last = "6-8"
		else
			referee_three_last = referee_three_last.to_s
		end
		@referee_part = Refereestatic.where("referee_one = ? AND referee_two = ? AND referee_three = ?", referee_one_last, referee_two_last, referee_three_last).first

		@referee_part_one = Referee.where("referee_one = ?", @game.referee_one).or(Referee.where("referee_two = ?", @game.referee_one).or(Referee.where("referee_three = ?", @game.referee_one)))
		@referee_part_one_last = Referee.where("referee_one = ? AND id < 43558", @game.referee_one).or(Referee.where("referee_two = ? AND id < 43558", @game.referee_one).or(Referee.where("referee_three = ? AND id < 43558", @game.referee_one).or(Referee.where("referee_one = ? AND id > 61549", @game.referee_one).or(Referee.where("referee_two = ? AND id > 61549", @game.referee_one).or(Referee.where("referee_three = ? AND id > 61549", @game.referee_one))))))
		@referee_part_two = Referee.where("referee_one = ?", @game.referee_two).or(Referee.where("referee_two = ?", @game.referee_two).or(Referee.where("referee_three = ?", @game.referee_two)))
		@referee_part_two_last = Referee.where("referee_one = ? AND id < 43558", @game.referee_two).or(Referee.where("referee_two = ? AND id < 43558", @game.referee_two).or(Referee.where("referee_three = ? AND id < 43558", @game.referee_two).or(Referee.where("referee_one = ? AND id > 61549", @game.referee_two).or(Referee.where("referee_two = ? AND id > 61549", @game.referee_two).or(Referee.where("referee_three = ? AND id > 61549", @game.referee_two))))))
		@referee_part_three = Referee.where("referee_one = ?", @game.referee_three).or(Referee.where("referee_two = ?", @game.referee_three).or(Referee.where("referee_three = ?", @game.referee_three)))
		@referee_part_three_last = Referee.where("referee_one = ? AND id < 43558", @game.referee_three).or(Referee.where("referee_two = ? AND id < 43558", @game.referee_three).or(Referee.where("referee_three = ? AND id < 43558", @game.referee_three).or(Referee.where("referee_one = ? AND id > 61549", @game.referee_three).or(Referee.where("referee_two = ? AND id > 61549", @game.referee_three).or(Referee.where("referee_three = ? AND id > 61549", @game.referee_three))))))
	end

	def state
		@match = {
	  		'GS' => 'GSW',
	  		'NY' => 'NYK',
	  		'PHX' => 'PHO',
	  		'SA' => 'SAS',
	  		'UTAH' => 'UTA',
	  		'WSH' => 'WAS',
	  		'NO' => 'NOP'
	  	}
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

		@away_last = Nba.where("home_abbr = ? AND game_date < ? AND total_point != 0", @away_abbr, @now).or(Nba.where("away_abbr = ? AND game_date < ? AND total_point != 0", @away_abbr, @now)).order(:game_date).last
		@home_last = Nba.where("home_abbr = ? AND game_date < ? AND total_point != 0", @home_abbr, @now).or(Nba.where("away_abbr = ? AND game_date < ? AND total_point != 0", @home_abbr, @now)).order(:game_date).last
		
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

		@away_players = @away_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @away_flag).order(:state).to_a
		@away_players_search = @away_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @away_flag).order(:state)
		@away_players_group1 = []
		@away_players_group2 = []
		@away_players_group3 = @away_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @away_flag).order(:state).to_a
		@away_starter_abbr = @away_abbr
		@away_starter_abbr = @match[@away_starter_abbr] if @match[@away_starter_abbr]
		@away_starters = Starter.where('team = ? AND time = ?', @away_starter_abbr, DateTime.parse(@game.game_date).strftime("%FT%T+00:00")).order(:index)
		@away_starters.each do |away_starter|
			selected_player = @away_players_search.select {|element|
				player_name = element.player_fullname
				player_name = player_name.gsub('-', ' ')
				element_index = player_name.rindex(" ")
				player_name = away_starter.player_name
				player_name = player_name.gsub('-', ' ')
				away_starter_index = player_name.rindex(" ")
				element.player_fullname[element_index+1..-1] == away_starter.player_name[away_starter_index+1..-1]}.first
			if selected_player
				selected_player.position = away_starter.position
				@away_players_group3.delete(selected_player)
				if away_starter.position == 'PG' || away_starter.position == 'SG'
					@away_players_group1.push(selected_player)
				else
					@away_players_group2.push(selected_player)
				end
			else
				additional_player = Player.where("player_fullname = ? AND game_date < ?", away_starter.player_name, @now).order(:game_date).last
				unless additional_player
					additional_player = Player.where("player_name = ? AND game_date < ?", away_starter.player_name, @now).order(:game_date).last
				end
				if away_starter.player_name == 'J.R. Smith'
					additional_player = Player.where("link = 'http://www.espn.com/nba/player/_/id/2444/jr-smith' AND game_date < ?", @now).order(:game_date).last
				elsif away_starter.player_name == 'Taurean Prince'
					additional_player = Player.where("player_fullname = 'Taurean Waller-Prince' AND game_date < ?", @now).order(:game_date).last
				end
				if additional_player
					additional_player.position = away_starter.position
					@away_players.push(additional_player)
					if away_starter.position == 'PG' || away_starter.position == 'SG'
						@away_players_group1.push(additional_player)
					else
						@away_players_group2.push(additional_player)
					end
				end
			end
		end

		@home_players = @home_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @home_flag).order(:state).to_a
		@home_players_search = @home_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @home_flag).order(:state)
		@home_players_group1 = []
		@home_players_group2 = []
		@home_players_group3 = @home_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @home_flag).order(:state).to_a
		@home_starter_abbr = @home_abbr
		@home_starter_abbr = @match[@home_starter_abbr] if @match[@home_starter_abbr]
		@home_starters = Starter.where('team = ? AND time = ?', @home_starter_abbr, DateTime.parse(@game.game_date).strftime("%FT%T+00:00")).order(:index)
		@home_starters.each do |home_starter|
			selected_player = @home_players_search.select {|element|
				player_name = element.player_fullname
				player_name = player_name.gsub('-', ' ')
				element_index = player_name.rindex(" ")
				player_name = home_starter.player_name
				player_name = player_name.gsub('-', ' ')
				home_starter_index = player_name.rindex(" ")
				element.player_fullname[element_index+1..-1] == home_starter.player_name[home_starter_index+1..-1]}.first
			if selected_player
				selected_player.position = home_starter.position
				@home_players_group3.delete(selected_player)
				if home_starter.position == 'PG' || home_starter.position == 'SG'
					@home_players_group1.push(selected_player)
				else
					@home_players_group2.push(selected_player)
				end
			else
				additional_player = Player.where("player_fullname = ? AND game_date < ?", home_starter.player_name, @now).order(:game_date).last
				unless additional_player
					additional_player = Player.where("player_name = ? AND game_date < ?", home_starter.player_name, @now).order(:game_date).last
				end
				if home_starter.player_name == 'J.R. Smith'
					additional_player = Player.where("link = 'http://www.espn.com/nba/player/_/id/2444/jr-smith' AND game_date < ?", @now).order(:game_date).last
				elsif home_starter.player_name == 'Taurean Prince'
					additional_player = Player.where("player_fullname = 'Taurean Waller-Prince' AND game_date < ?", @now).order(:game_date).last
				end
				if additional_player
					additional_player.position = home_starter.position
					@home_players.push(additional_player)
					if home_starter.position == 'PG' || home_starter.position == 'SG'
						@home_players_group1.push(additional_player)
					else
						@home_players_group2.push(additional_player)
					end
				end
			end
		end

		@home_injury = Injury.where("team = ? AND today = ?", @game.home_team, Date.today)
		@home_injury = Injury.where("team = ? AND today = ?", @game.home_team, Date.yesterday) unless @home_injury.size
		@away_injury = Injury.where("team = ? AND today = ?", @game.away_team, Date.today)
		@away_injury = Injury.where("team = ? AND today = ?", @game.away_team, Date.yesterday) unless @away_injury.size

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
        @injury_away_total_pf = 0
        @injury_away_total_or = 0
        @injury_away_total_to = 0
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_away_total_min = @injury_away_total_min + player.sum_mins/(count - 2)
	        @injury_away_total_stl = @injury_away_total_stl + player.sum_stl.to_f/count
	        @injury_away_total_blk = @injury_away_total_blk + player.sum_blk.to_f/count
	        @injury_away_total_to = @injury_away_total_to + player.sum_to.to_f/count
	        @injury_away_total_pf = @injury_away_total_pf + player.sum_pf.to_i/count
	        @injury_away_total_or = @injury_away_total_or + player.sum_or.to_f/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_away_drtg_one = @injury_away_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @injury_away_drtg_one_container.push(player.id)
	        @injury_away_total_poss = @injury_away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    if injury_drtg_count < 3
	    	@away_players_group4 = @away_players_group3.select {|element| element.position == 'PG' || element.position == 'SG'}
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_away_total_min = @injury_away_total_min + player.sum_mins/(count - 2)
	        @injury_away_total_stl = @injury_away_total_stl + player.sum_stl.to_f/count
	        @injury_away_total_blk = @injury_away_total_blk + player.sum_blk.to_f/count
	        @injury_away_total_to = @injury_away_total_to + player.sum_to.to_f/count
	        @injury_away_total_pf = @injury_away_total_pf + player.sum_pf.to_i/count
	        @injury_away_total_or = @injury_away_total_or + player.sum_or.to_f/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_away_drtg_two = @injury_away_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @injury_away_drtg_two_container.push(player.id)
	        @injury_away_total_poss = @injury_away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    if injury_drtg_count < 3
	    	@away_players_group4 = @away_players_group3.select {|element| element.position == 'C' || element.position == 'SF' || element.position == 'PF' }
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        if @away_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        @injury_away_total_min = @injury_away_total_min + player.sum_mins/(count - 2)
	        @injury_away_total_stl = @injury_away_total_stl + player.sum_stl.to_f/count
	        @injury_away_total_blk = @injury_away_total_blk + player.sum_blk.to_f/count
	        @injury_away_total_to = @injury_away_total_to + player.sum_to.to_f/count
	        @injury_away_total_pf = @injury_away_total_pf + player.sum_pf.to_i/count
	        @injury_away_total_or = @injury_away_total_or + player.sum_or.to_f/count
	        @injury_away_total_poss = @injury_away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    @injury_home_total_poss = 0
	    @injury_home_total_min = 0
        @injury_home_total_stl = 0
        @injury_home_total_to = 0
        @injury_home_total_blk = 0
        @injury_home_total_pf = 0
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_home_total_min = @injury_home_total_min + player.sum_mins/(count - 2)
	        @injury_home_total_stl = @injury_home_total_stl + player.sum_stl.to_f/count
	        @injury_home_total_to = @injury_home_total_to + player.sum_to.to_f/count
	        @injury_home_total_blk = @injury_home_total_blk + player.sum_blk.to_f/count
	        @injury_home_total_pf = @injury_home_total_pf + player.sum_pf.to_i/count
	        @injury_home_total_or = @injury_home_total_or + player.sum_or.to_f/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_home_drtg_one = @injury_home_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @injury_home_total_poss = @injury_home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @injury_home_drtg_one_container.push(player.id)
	    end
	    if injury_drtg_count < 3
	    	@home_players_group4 = @home_players_group3.select {|element| element.position == 'PG' || element.position == 'SG'}
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        injury_drtg_count = injury_drtg_count + 1
	        @injury_home_total_min = @injury_home_total_min + player.sum_mins/(count - 2)
	        @injury_home_total_stl = @injury_home_total_stl + player.sum_stl.to_f/count
	        @injury_home_total_to = @injury_home_total_to + player.sum_to.to_f/count
	        @injury_home_total_blk = @injury_home_total_blk + player.sum_blk.to_f/count
	        @injury_home_total_pf = @injury_home_total_pf + player.sum_pf.to_i/count
	        @injury_home_total_or = @injury_home_total_or + player.sum_or.to_f/count
	        injury_drtg_min = injury_drtg_min + player.sum_mins/(count - 2)
	        @injury_home_drtg_two = @injury_home_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @injury_home_total_poss = @injury_home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @injury_home_drtg_two_container.push(player.id)
	    end
	    if injury_drtg_count < 3
	    	@home_players_group4 = @home_players_group3.select {|element| element.position == 'C' || element.position == 'SF' || element.position == 'PF'}
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        if @home_injury_name.include?(player.player_name) && !@injuries.include?(player.id.to_s)
	        	next
	        end
	        @injury_home_total_min = @injury_home_total_min + player.sum_mins/(count - 2)
	        @injury_home_total_stl = @injury_home_total_stl + player.sum_stl.to_f/count
	        @injury_home_total_to = @injury_home_total_to + player.sum_to.to_f/count
	        @injury_home_total_blk = @injury_home_total_blk + player.sum_blk.to_f/count
	        @injury_home_total_pf = @injury_home_total_pf + player.sum_pf.to_i/count
	        @injury_home_total_or = @injury_home_total_or + player.sum_or.to_f/count
	        @injury_home_total_poss = @injury_home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    @away_total_poss = 0
	    @away_total_min = 0
        @away_total_stl = 0
        @away_total_to = 0
        @away_total_blk = 0
        @away_total_pf = 0
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        drtg_count = drtg_count + 1
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        @away_total_stl = @away_total_stl + player.sum_stl.to_f/count
	        @away_total_to = @away_total_to + player.sum_to.to_f/count
	        @away_total_blk = @away_total_blk + player.sum_blk.to_f/count
	        @away_total_pf = @away_total_pf + player.sum_pf.to_i/count
	        @away_total_or = @away_total_or + player.sum_or.to_f/count
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @away_drtg_one = @away_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @away_drtg_one_container.push(player.id)
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    if drtg_count < 3
	    	@away_players_group4 = @away_players_group3.select {|element| element.position == 'PG' || element.position == 'SG' }
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        drtg_count = drtg_count + 1
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        @away_total_stl = @away_total_stl + player.sum_stl.to_f/count
	        @away_total_to = @away_total_to + player.sum_to.to_f/count
	        @away_total_blk = @away_total_blk + player.sum_blk.to_f/count
	        @away_total_pf = @away_total_pf + player.sum_pf.to_i/count
	        @away_total_or = @away_total_or + player.sum_or.to_f/count
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @away_drtg_two = @away_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @away_drtg_two_container.push(player.id)
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	    if drtg_count < 3
	    	@away_players_group4 = @away_players_group3.select {|element| element.position == 'C' || element.position == 'SF' || element.position == 'PF' }
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        @away_total_min = @away_total_min + player.sum_mins/(count - 2)
	        @away_total_stl = @away_total_stl + player.sum_stl.to_f/count
	        @away_total_to = @away_total_to + player.sum_to.to_f/count
	        @away_total_blk = @away_total_blk + player.sum_blk.to_f/count
	        @away_total_pf = @away_total_pf + player.sum_pf.to_i/count
	        @away_total_or = @away_total_or + player.sum_or.to_f/count
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end

	    @home_total_poss = 0
	    @home_total_min = 0
        @home_total_stl = 0
        @home_total_to = 0
        @home_total_blk = 0
        @home_total_pf = 0
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        drtg_count = drtg_count + 1
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        @home_total_stl = @home_total_stl + player.sum_stl.to_f/count
	        @home_total_to = @home_total_to + player.sum_to.to_f/count
	        @home_total_blk = @home_total_blk + player.sum_blk.to_f/count
	        @home_total_pf = @home_total_pf + player.sum_pf.to_i/count
	        @home_total_or = @home_total_or + player.sum_or.to_f/count
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @home_drtg_one = @home_drtg_one + player.drtg * (player.sum_mins/(count - 2))
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @home_drtg_one_container.push(player.id)
	    end
	    if drtg_count < 3
	    	@home_players_group4 = @home_players_group3.select {|element| element.position == 'PG' || element.position == 'SG'}
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        drtg_count = drtg_count + 1
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        @home_total_stl = @home_total_stl + player.sum_stl.to_f/count
	        @home_total_to = @home_total_to + player.sum_to.to_f/count
	        @home_total_blk = @home_total_blk + player.sum_blk.to_f/count
	        @home_total_pf = @home_total_pf + player.sum_pf.to_i/count
	        @home_total_or = @home_total_or + player.sum_or.to_f/count
	        drtg_min = drtg_min + player.sum_mins/(count - 2)
	        @home_drtg_two = @home_drtg_two + player.drtg * (player.sum_mins/(count - 2))
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	        @home_drtg_two_container.push(player.id)
	    end
	    if drtg_count < 3
	    	@home_players_group4 = @home_players_group3.select {|element| element.position == 'C' || element.position == 'SF' || element.position == 'PF'}
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
		        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
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
	        if !player.sum_mins || player.sum_mins/(count - 2) < 10 || count < 10
	        	next
	        end
	        @home_total_min = @home_total_min + player.sum_mins/(count - 2)
	        @home_total_stl = @home_total_stl + player.sum_stl.to_f/count
	        @home_total_to = @home_total_to + player.sum_to.to_f/count
	        @home_total_blk = @home_total_blk + player.sum_blk.to_f/count
	        @home_total_pf = @home_total_pf + player.sum_pf.to_i/count
	        @home_total_or = @home_total_or + player.sum_or.to_f/count
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
	    end
	end


	def rest
		@match = {
	  		'GS' => 'GSW',
	  		'NY' => 'NYK',
	  		'PHX' => 'PHO',
	  		'SA' => 'SAS',
	  		'UTAH' => 'UTA',
	  		'WSH' => 'WAS',
	  		'NO' => 'NOP'
	  	}
		@game_id = params[:id]
		@game = Nba.find_by(game_id: @game_id)
		@head = @game.away_team + " @ " + @game.home_team
		
		@home_abbr = @game.home_abbr
		@away_abbr = @game.away_abbr

		@now = Date.strptime(@game.game_date)
		if @now > Time.now
			@now = Time.now
		end

		@away_last = Nba.where("home_abbr = ? AND game_date < ? AND total_point != 0", @away_abbr, @now).or(Nba.where("away_abbr = ? AND game_date < ? AND total_point != 0", @away_abbr, @now)).order(:game_date).last
		@home_last = Nba.where("home_abbr = ? AND game_date < ? AND total_point != 0", @home_abbr, @now).or(Nba.where("away_abbr = ? AND game_date < ? AND total_point != 0", @home_abbr, @now)).order(:game_date).last
		
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

		@away_players = @away_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @away_flag).order(:state).to_a
		@away_players_search = @away_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @away_flag).order(:state)
		@away_players_group1 = []
		@away_players_group2 = []
		@away_players_group3 = @away_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @away_flag).order(:state).to_a
		@away_starter_abbr = @away_abbr
		@away_starter_abbr = @match[@away_starter_abbr] if @match[@away_starter_abbr]
		@away_starters = Starter.where('team = ? AND time = ?', @away_starter_abbr, DateTime.parse(@game.game_date).strftime("%FT%T+00:00")).order(:index)
		@away_starters.each do |away_starter|
			selected_player = @away_players_search.select {|element|
				player_name = element.player_fullname
				player_name = player_name.gsub('-', ' ')
				element_index = player_name.rindex(" ")
				player_name = away_starter.player_name
				player_name = player_name.gsub('-', ' ')
				away_starter_index = player_name.rindex(" ")
				element.player_fullname[element_index+1..-1] == away_starter.player_name[away_starter_index+1..-1]}.first
			if selected_player
				selected_player.position = away_starter.position
				@away_players_group3.delete(selected_player)
				if away_starter.position == 'PG' || away_starter.position == 'SG'
					@away_players_group1.push(selected_player)
				else
					@away_players_group2.push(selected_player)
				end
			else
				additional_player = Player.where("player_fullname = ? AND game_date < ?", away_starter.player_name, @now).order(:game_date).last
				unless additional_player
					additional_player = Player.where("player_name = ? AND game_date < ?", away_starter.player_name, @now).order(:game_date).last
				end
				if away_starter.player_name == 'J.R. Smith'
					additional_player = Player.where("link = 'http://www.espn.com/nba/player/_/id/2444/jr-smith' AND game_date < ?", @now).order(:game_date).last
				elsif away_starter.player_name == 'Taurean Prince'
					additional_player = Player.where("player_fullname = 'Taurean Waller-Prince' AND game_date < ?", @now).order(:game_date).last
				end
				if additional_player
					additional_player.position = away_starter.position
					@away_players.push(additional_player)
					if away_starter.position == 'PG' || away_starter.position == 'SG'
						@away_players_group1.push(additional_player)
					else
						@away_players_group2.push(additional_player)
					end
				end
			end
		end

		@home_players = @home_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @home_flag).order(:state).to_a
		@home_players_search = @home_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @home_flag).order(:state)
		@home_players_group1 = []
		@home_players_group2 = []
		@home_players_group3 = @home_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @home_flag).order(:state).to_a
		@home_starter_abbr = @home_abbr
		@home_starter_abbr = @match[@home_starter_abbr] if @match[@home_starter_abbr]
		@home_starters = Starter.where('team = ? AND time = ?', @home_starter_abbr, DateTime.parse(@game.game_date).strftime("%FT%T+00:00")).order(:index)
		@home_starters.each do |home_starter|
			selected_player = @home_players_search.select {|element|
				player_name = element.player_fullname
				player_name = player_name.gsub('-', ' ')
				element_index = player_name.rindex(" ")
				player_name = home_starter.player_name
				player_name = player_name.gsub('-', ' ')
				home_starter_index = player_name.rindex(" ")
				element.player_fullname[element_index+1..-1] == home_starter.player_name[home_starter_index+1..-1]}.first
			if selected_player
				selected_player.position = home_starter.position
				@home_players_group3.delete(selected_player)
				if home_starter.position == 'PG' || home_starter.position == 'SG'
					@home_players_group1.push(selected_player)
				else
					@home_players_group2.push(selected_player)
				end
			else
				additional_player = Player.where("player_fullname = ? AND game_date < ?", home_starter.player_name, @now).order(:game_date).last
				unless additional_player
					additional_player = Player.where("player_name = ? AND game_date < ?", home_starter.player_name, @now).order(:game_date).last
				end
				if home_starter.player_name == 'J.R. Smith'
					additional_player = Player.where("link = 'http://www.espn.com/nba/player/_/id/2444/jr-smith' AND game_date < ?", @now).order(:game_date).last
				elsif home_starter.player_name == 'Taurean Prince'
					additional_player = Player.where("player_fullname = 'Taurean Waller-Prince' AND game_date < ?", @now).order(:game_date).last
				end
				if additional_player
					additional_player.position = home_starter.position
					@home_players.push(additional_player)
					if home_starter.position == 'PG' || home_starter.position == 'SG'
						@home_players_group1.push(additional_player)
					else
						@home_players_group2.push(additional_player)
					end
				end
			end
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
	    	[false, true, false, true, true, false, true, false],
	    	[true, true, false, false, false, false, true, true]
		]
		@break = [9, 15, 16]
		@filterResult = []
		@filterResult_secondtravel = []
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
			filter_element_secondtravel = Secondtravel.where(search_string)
			filter_second_element_secondtravel = Secondtravel.where(search_second_string)
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
				bj: filter_second_element.average(:fgside).to_f.round(2),
				bg: filter_second_element.average(:firstside).to_f.round(2),
				bh: filter_second_element.average(:secondside).to_f.round(2),
				first_under: filter_second_element.where("firstou = 'under'").count,
				first_over: filter_second_element.where("firstou = 'over'").count,
				second_under: filter_second_element.where("secondou = 'under'").count,
				second_over: filter_second_element.where("secondou = 'over'").count,
				first_half_away: filter_second_element.where("first_half_bigger = 'AWAY'").count,
				first_half_home: filter_second_element.where("first_half_bigger = 'HOME'").count,
				second_half_away: filter_second_element.where("second_half_bigger = 'AWAY'").count,
				second_half_home: filter_second_element.where("second_half_bigger = 'HOME'").count
			}
			result_element_secondtravel = {
				first: filter_element_secondtravel.average(:firstvalue).to_f.round(2),
				second: filter_element_secondtravel.average(:secondvalue).to_f.round(2),
				full: filter_element_secondtravel.average(:totalvalue).to_f.round(2),
				count: filter_element_secondtravel.count(:totalvalue).to_i,
				allfirst: filter_second_element_secondtravel.average(:firstvalue).to_f.round(2),
				allsecond: filter_second_element_secondtravel.average(:secondvalue).to_f.round(2),
				allfull: filter_second_element_secondtravel.average(:totalvalue).to_f.round(2),
				allcount: filter_second_element_secondtravel.count(:totalvalue).to_i,
				bj: filter_second_element_secondtravel.average(:fgside).to_f.round(2),
				bg: 0,
				bh: 0
			}
			if index < 2 || index > 9
				result_element[:full_first] = (filter_second_element.average(:roadthird).to_f + filter_second_element.average(:roadforth).to_f + filter_second_element.average(:roadfirsthalf).to_f).round(2)
				result_element[:full_second] = (filter_second_element.average(:homethird).to_f + filter_second_element.average(:homeforth).to_f + filter_second_element.average(:homefirsthalf).to_f).round(2)
				result_element[:firsthalf_first] = filter_second_element.average(:roadfirsthalf).to_f.round(2)
				result_element[:firsthalf_second] = filter_second_element.average(:homefirsthalf).to_f.round(2)
				result_element[:secondhalf_first] = (filter_second_element.average(:roadthird).to_f.round(2) + filter_second_element.average(:roadforth).to_f.round(2)).round(2)
				result_element[:secondhalf_second] = (filter_second_element.average(:homethird).to_f.round(2) + filter_second_element.average(:homeforth).to_f.round(2)).round(2)
				filter_second_element_again = filter_second_element.where("firstlinetotal is not null AND firstlinetotal != 0")
				result_element[:bi_one] = (filter_second_element_again.average(:roadfirsthalf).to_f - filter_second_element_again.average(:homefirsthalf).to_f).round(2)
				result_element[:bi_two] = (filter_second_element_again.average(:roadthird).to_f + filter_second_element_again.average(:roadforth).to_f - filter_second_element_again.average(:homethird).to_f - filter_second_element_again.average(:homeforth).to_f).round(2)
				result_element[:bi_count] = filter_second_element_again.count(:firstlinetotal).to_i
				result_element_secondtravel[:full_first] = (filter_second_element_secondtravel.average(:roadthird).to_f + filter_second_element_secondtravel.average(:roadforth).to_f + filter_second_element_secondtravel.average(:roadfirsthalf).to_f).round(2)
				result_element_secondtravel[:full_second] = (filter_second_element_secondtravel.average(:homethird).to_f + filter_second_element_secondtravel.average(:homeforth).to_f + filter_second_element_secondtravel.average(:homefirsthalf).to_f).round(2)
				result_element_secondtravel[:firsthalf_first] = filter_second_element_secondtravel.average(:roadfirsthalf).to_f.round(2)
				result_element_secondtravel[:firsthalf_second] = filter_second_element_secondtravel.average(:homefirsthalf).to_f.round(2)
				result_element_secondtravel[:secondhalf_first] = (filter_second_element_secondtravel.average(:roadthird).to_f.round(2) + filter_second_element_secondtravel.average(:roadforth).to_f.round(2)).round(2)
				result_element_secondtravel[:secondhalf_second] = (filter_second_element_secondtravel.average(:homethird).to_f.round(2) + filter_second_element_secondtravel.average(:homeforth).to_f.round(2)).round(2)
			end
			@filterResult.push(result_element)
			@filterResult_secondtravel.push(result_element_secondtravel)
		end
		@home_team_info = Team.find_by(abbr: @home_abbr)
    	@away_team_info = Team.find_by(abbr: @away_abbr)
    	@away_last_games = Nba.where("home_team = ? AND game_date < ?", @game.away_team, @game.game_date).or(Nba.where("away_team = ? AND game_date < ?", @game.away_team, @game.game_date)).order(game_date: :desc).limit(12)
    	@away_stl = 0
	    @away_blk = 0
	    @away_or = 0
	    @away_to = 0
	    @away_last_games.each do |last_game|
	        if last_game.home_team == @game.away_team
	        	@away_stl = @away_stl + last_game.home_stl.to_i
	         	@away_blk = @away_blk + last_game.home_blk.to_i
	        	@away_or = @away_or + last_game.home_orValue.to_i
	         	@away_to = @away_to + last_game.home_toValue.to_i
	        else
	          	@away_stl = @away_stl + last_game.away_stl.to_i
	          	@away_blk = @away_blk + last_game.away_blk.to_i
	        	@away_or = @away_or + last_game.away_orValue.to_i
	         	@away_to = @away_to + last_game.away_toValue.to_i
	        end
	    end
	    @away_count = @away_last_games.count
	    if @away_count
	    	@away_stl = (@away_stl.to_f / @away_count).round(2)
	        @away_blk = (@away_blk.to_f / @away_count).round(2)
	        @away_or = (@away_or.to_f / @away_count).round(2)
	        @away_to = (@away_to.to_f / @away_count).round(2)
	    end

    	@home_last_games = Nba.where("home_team = ? AND game_date < ?", @game.home_team, @game.game_date).or(Nba.where("away_team = ? AND game_date < ?", @game.home_team, @game.game_date)).order(game_date: :desc).limit(12)
    	@home_stl = 0
	    @home_blk = 0
	    @home_or = 0
	    @home_to = 0

      	@home_last_games.each do |last_game|
	        if last_game.home_team == @game.home_team
	        	@home_stl = @home_stl + last_game.home_stl.to_i
	          	@home_blk = @home_blk + last_game.home_blk.to_i
	        	@home_or = @home_or + last_game.home_orValue.to_i
	         	@home_to = @home_to + last_game.home_toValue.to_i
	        else
	          	@home_stl = @home_stl + last_game.away_stl.to_i
	          	@home_blk = @home_blk + last_game.away_blk.to_i
	        	@home_or = @home_or + last_game.away_orValue.to_i
	         	@home_to = @home_to + last_game.away_toValue.to_i
	        end
	    end
	    @home_count = @home_last_games.count
	    if @home_count
	        @home_stl = (@home_stl.to_f / @home_count).round(2)
	        @home_blk = (@home_blk.to_f / @home_count).round(2)
	        @home_or = (@home_or.to_f / @home_count).round(2)
	        @home_to = (@home_to.to_f / @home_count).round(2)
	    end

	    @away_players_starters = @away_players_group1 + @away_players_group2
	    @home_players_starters = @home_players_group1 + @home_players_group2

	    @away_avg_stl = 0
	    @away_avg_blk = 0
	    @away_avg_or = 0
	    @away_avg_to = 0
	    @away_players_starters.each do |player|
	    	last_players = Player.where("player_name = ? AND mins <> 0", player.player_name).order(game_date: :desc).limit(12)
	    	average_mins = 0
	    	average_stl = 0
	    	average_blk = 0
	    	average_or = 0
	    	average_to = 0
	    	last_players_count = last_players.count
	    	last_players.each do |last_player|
	    		average_mins = average_mins + last_player.mins
	    		average_stl = average_stl + last_player.stlValue
	    		average_blk = average_blk + last_player.blkValue
	    		average_or = average_or + last_player.orValue
	    		average_to = average_to + last_player.toValue
	    	end
	    	average_mins = average_mins.to_f / last_players_count
	    	average_stl = average_stl.to_f / last_players_count
	    	average_blk = average_blk.to_f / last_players_count
	    	average_or = average_or.to_f / last_players_count
	    	average_to = average_to.to_f / last_players_count
	    	@away_avg_stl = @away_avg_stl + 48 / average_mins * average_stl
	    	@away_avg_blk = @away_avg_blk + 48 / average_mins * average_blk
	    	@away_avg_or = @away_avg_or + 48 / average_mins * average_or
	    	@away_avg_to = @away_avg_to + 48 / average_mins * average_to
	    end

	    @home_avg_stl = 0
	    @home_avg_blk = 0
	    @home_avg_or = 0
	    @home_avg_to = 0
	    @home_players_starters.each do |player|
	    	last_players = Player.where("player_name = ? AND mins <> 0", player.player_name).order(game_date: :desc).limit(12)
	    	average_mins = 0
	    	average_stl = 0
	    	average_blk = 0
	    	average_or = 0
	    	average_to = 0
	    	last_players_count = last_players.count
	    	last_players.each do |last_player|
	    		average_mins = average_mins + last_player.mins
	    		average_stl = average_stl + last_player.stlValue
	    		average_blk = average_blk + last_player.blkValue
	    		average_or = average_or + last_player.orValue
	    		average_to = average_to + last_player.toValue
	    	end
	    	average_mins = average_mins.to_f / last_players_count
	    	average_stl = average_stl.to_f / last_players_count
	    	average_blk = average_blk.to_f / last_players_count
	    	average_or = average_or.to_f / last_players_count
	    	average_to = average_to.to_f / last_players_count
	    	@home_avg_stl = @home_avg_stl + 48 / average_mins * average_stl
	    	@home_avg_blk = @home_avg_blk + 48 / average_mins * average_blk
	    	@home_avg_or = @home_avg_or + 48 / average_mins * average_or
	    	@home_avg_to = @home_avg_to + 48 / average_mins * average_to
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
		
		secondItem_secondtravel = Secondtravel.where(hometeam: @game.home_team)
		thirdItem_secondtravel = Secondtravel.where(week: @game.week)
		@firstItem_result_secondtravel = {
			first: '',
			second: '',
			full: '',
			count: ''
		}
		@secondItem_result_secondtravel = {
			first: secondItem_secondtravel.average(:firstpoint).to_f.round(2),
			second: secondItem_secondtravel.average(:secondpoint).to_f.round(2),
			full: secondItem_secondtravel.average(:totalpoint).to_f.round(2),
			count: secondItem_secondtravel.count(:totalpoint).to_i
		}
		@thirdItem_result_secondtravel = {
			first: thirdItem_secondtravel.average(:firstpoint).to_f.round(2),
			second: thirdItem_secondtravel.average(:secondpoint).to_f.round(2),
			full: thirdItem_secondtravel.average(:totalpoint).to_f.round(2),
			count: thirdItem_secondtravel.count(:totalpoint).to_i
		}

    @game_date = DateTime.parse(@game.game_date)
    year = @game_date.year
    date = @game_date.strftime("%b-%-d")

    @countItem = Fullseason.where("awaylastfly = ? AND awaynextfly = ? AND roadlast = ? AND roadnext = ? AND homenext = ? AND homelast = ? AND homenextfly = ? AND homelastfly = ?", @game.away_last_fly, @game.away_next_fly, @game.away_last_game, @game.away_next_game, @game.home_next_game, @game.home_last_game, @game.home_next_fly, @game.home_last_fly)
    @countItem = @countItem.where("roadteam != ? OR year != ? OR date != ?", @game.away_team, year, date)
    @secondItem = Secondtravel.where("awaylastfly = ? AND awaynextfly = ? AND roadlast = ? AND roadnext = ? AND homenext = ? AND homelast = ? AND homenextfly = ? AND homelastfly = ?", @game.away_last_fly, @game.away_next_fly, @game.away_last_game, @game.away_next_game, @game.home_next_game, @game.home_last_game, @game.home_next_fly, @game.home_last_fly)
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
		referee_one_last = 200 if referee_one_last == nil
		referee_two_last = 200 if referee_two_last == nil
		referee_three_last = 200 if referee_three_last == nil
		if referee_one_last == referee_two_last && referee_two_last == referee_three_last
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

		referee_one_next = 200 if referee_one_next == nil
		referee_two_next = 200 if referee_two_next == nil
		referee_three_next = 200 if referee_three_next == nil

		if referee_one_next == referee_two_next && referee_two_next == referee_three_next
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
					if referee_filter_element[0] > 8
						search_array.push("referee_one_last > 8")
					elsif referee_filter_element[0] > 5
						search_array.push("referee_one_last > 5 AND referee_one_last < 9")
					else
						search_array.push("referee_one_last = #{referee_filter_element[0]}")
					end
					if referee_filter_element[1] > 8
						search_array.push("referee_two_last > 8")
					elsif referee_filter_element[1] > 5
						search_array.push("referee_two_last > 5 AND referee_two_last < 9")
					else
						search_array.push("referee_two_last = #{referee_filter_element[1]}")
					end
					if referee_filter_element[2] > 8
						search_array.push("referee_three_last > 8")
					elsif referee_filter_element[2] > 5
						search_array.push("referee_three_last > 5 AND referee_three_last < 9")
					else
						search_array.push("referee_three_last = #{referee_filter_element[2]}")
					end
				else
					if referee_filter_element[0] > 8
						search_array.push("referee_one_next > 8")
					elsif referee_filter_element[0] > 5
						search_array.push("referee_one_next > 5 AND referee_one_next < 9")
					else
						search_array.push("referee_one_next = #{referee_filter_element[0]}")
					end
					if referee_filter_element[1] > 8
						search_array.push("referee_two_next > 8")
					elsif referee_filter_element[1] > 5
						search_array.push("referee_two_next > 5 AND referee_two_next < 9")
					else
						search_array.push("referee_two_next = #{referee_filter_element[1]}")
					end
					if referee_filter_element[2] > 8
						search_array.push("referee_three_next > 8")
					elsif referee_filter_element[2] > 5
						search_array.push("referee_three_next > 5 AND referee_three_next < 9")
					else
						search_array.push("referee_three_next = #{referee_filter_element[2]}")
					end
				end
				search_array = search_array.join(" AND ")
				referee_filter_result = Referee.where(search_array)
				@referee_filter_results.push([
					referee_filter_result.average(:tp_1h).to_f.round(2),
					referee_filter_result.average(:tp_2h).to_f.round(2),
					(referee_filter_result.average(:away_pf).to_f.round(2) + referee_filter_result.average(:home_pf).to_f.round(2)).round(2),
					(referee_filter_result.average(:away_fta).to_f.round(2) + referee_filter_result.average(:home_fta).to_f.round(2)).round(2),
					referee_filter_result.count(:tp_1h).to_i
				])
			else
				@referee_filter_results.push(['-', '-',	'-', '-', '-'])
			end
		end

		if referee_one_last > referee_two_last
			temp = referee_one_last
			referee_one_last = referee_two_last
			referee_two_last = temp
		end

		if referee_one_last > referee_three_last
			temp = referee_one_last
			referee_one_last = referee_three_last
			referee_three_last = temp
		end

		if referee_two_last > referee_three_last
			temp = referee_two_last
			referee_two_last = referee_three_last
			referee_three_last = temp
		end

		if referee_one_last > 8
			referee_one_last = "9+"
		elsif referee_one_last > 5
			referee_one_last = "6-8"
		else
			referee_one_last = referee_one_last.to_s
		end

		if referee_two_last > 8
			referee_two_last = "9+"
		elsif referee_two_last > 5
			referee_two_last = "6-8"
		else
			referee_two_last = referee_two_last.to_s
		end

		if referee_three_last > 8
			referee_three_last = "9+"
		elsif referee_three_last > 5
			referee_three_last = "6-8"
		else
			referee_three_last = referee_three_last.to_s
		end
		@referee_part = Refereestatic.where("referee_one = ? AND referee_two = ? AND referee_three = ?", referee_one_last, referee_two_last, referee_three_last).first

		@referee_part_one = Referee.where("referee_one = ?", @game.referee_one).or(Referee.where("referee_two = ?", @game.referee_one).or(Referee.where("referee_three = ?", @game.referee_one)))
		@referee_part_one_last = Referee.where("referee_one = ? AND id < 43558", @game.referee_one).or(Referee.where("referee_two = ? AND id < 43558", @game.referee_one).or(Referee.where("referee_three = ? AND id < 43558", @game.referee_one).or(Referee.where("referee_one = ? AND id > 61549", @game.referee_one).or(Referee.where("referee_two = ? AND id > 61549", @game.referee_one).or(Referee.where("referee_three = ? AND id > 61549", @game.referee_one))))))
		@referee_part_two = Referee.where("referee_one = ?", @game.referee_two).or(Referee.where("referee_two = ?", @game.referee_two).or(Referee.where("referee_three = ?", @game.referee_two)))
		@referee_part_two_last = Referee.where("referee_one = ? AND id < 43558", @game.referee_two).or(Referee.where("referee_two = ? AND id < 43558", @game.referee_two).or(Referee.where("referee_three = ? AND id < 43558", @game.referee_two).or(Referee.where("referee_one = ? AND id > 61549", @game.referee_two).or(Referee.where("referee_two = ? AND id > 61549", @game.referee_two).or(Referee.where("referee_three = ? AND id > 61549", @game.referee_two))))))
		@referee_part_three = Referee.where("referee_one = ?", @game.referee_three).or(Referee.where("referee_two = ?", @game.referee_three).or(Referee.where("referee_three = ?", @game.referee_three)))
		@referee_part_three_last = Referee.where("referee_one = ? AND id < 43558", @game.referee_three).or(Referee.where("referee_two = ? AND id < 43558", @game.referee_three).or(Referee.where("referee_three = ? AND id < 43558", @game.referee_three).or(Referee.where("referee_one = ? AND id > 61549", @game.referee_three).or(Referee.where("referee_two = ? AND id > 61549", @game.referee_three).or(Referee.where("referee_three = ? AND id > 61549", @game.referee_three))))))
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
