namespace :nba do
	task :previous => :environment do
		date = Date.new(2009, 12, 30)
		while date >= Date.new(2009, 12, 30)
			Rake::Task["nba:getDate"].invoke(date.strftime("%Y%m%d"))
			Rake::Task["nba:getDate"].reenable
			date = date - 6.days
		end
	end

	task :daily => :environment do
		date = Date.yesterday
		Rake::Task["nba:getDate"].invoke(date.strftime("%Y%m%d"))
		Rake::Task["nba:getDate"].reenable

		Rake::Task["nba:getScore"].invoke
		Rake::Task["nba:getScore"].reenable

		Rake::Task["nba:getLinkGame"].invoke
		Rake::Task["nba:getLinkGame"].reenable

		Rake::Task["nba:getFirstLines"].invoke
		Rake::Task["nba:getFirstLines"].reenable

		Rake::Task["nba:getSecondLines"].invoke
		Rake::Task["nba:getSecondLines"].reenable

		Rake::Task["nba:getFullLines"].invoke
		Rake::Task["nba:getFullLines"].reenable

		Rake::Task["nba:gettg"].invoke
		Rake::Task["nba:gettg"].reenable

		Rake::Task["nba:getPlayer"].invoke
		Rake::Task["nba:getPlayer"].reenable

		Rake::Task["nba:getUpdateTG"].invoke
		Rake::Task["nba:getUpdateTG"].reenable

		Rake::Task["nba:getUpdatePoss"].invoke
		Rake::Task["nba:getUpdatePoss"].reenable

		Rake::Task["nba:getUpdateRate"].invoke
		Rake::Task["nba:getUpdateRate"].reenable
		
	end

	task :fix => :environment do
		include Api
		index = {
			team: 1, 
			current: 2,
			last_three: 3,
			last_one: 4,
			home: 5,
			away: 6,
			last: 7
		}

		url = "https://www.teamrankings.com/nba/stat/offensive-rebounds-per-game"
		doc = download_document(url)
		elements = doc.css(".dataTables_wrapper tbody tr")
		
		elements.each do |slice|
			team 		= 	slice.children[index[:team]].text
			current 	= 	slice.children[index[:current]].text.to_f
			last_three	= 	slice.children[index[:last_three]].text.to_f
			last_one	= 	slice.children[index[:last_one]].text.to_f
			home 		= 	slice.children[index[:home]].text.to_f
			away 		= 	slice.children[index[:away]].text.to_f
			last 		= 	slice.children[index[:last]].text.to_f
		
			unless element = Team.find_by(team: team)
	          	element = Team.create(team: team)
	        end
	        element.update(rebound_current: current, rebound_last_three: last_three, rebound_last_one: last_one, rebound_home: home, rebound_away: away, rebound_last: last)
		end

		url = "https://www.teamrankings.com/nba/stat/possessions-per-game"
		doc = download_document(url)
		elements = doc.css(".dataTables_wrapper tbody tr")
		
		elements.each do |slice|
			team 		= 	slice.children[index[:team]].text
			current 	= 	slice.children[index[:current]].text.to_f
			last_three	= 	slice.children[index[:last_three]].text.to_f
			last_one	= 	slice.children[index[:last_one]].text.to_f
			home 		= 	slice.children[index[:home]].text.to_f
			away 		= 	slice.children[index[:away]].text.to_f
			last 		= 	slice.children[index[:last]].text.to_f
		
			unless element = Team.find_by(team: team)
	          	element = Team.create(team: team)
	        end
	        element.update(possessions_current: current, possessions_last_three: last_three, possessions_last_one: last_one, possessions_home: home, possessions_away: away, possessions_last: last)
		end
	end

	task :getDate, [:game_date] => [:environment] do |t, args|
		puts "----------Get Games----------"
		include Api
		Time.zone = 'Eastern Time (US & Canada)'
		game_date = args[:game_date]
		url = "http://www.espn.com/nba/schedule/_/date/#{game_date}"
		doc = download_document(url)
		puts url
	  	index = { away_team: 0, home_team: 1, result: 2 }
	  	elements = doc.css("tr")
	  	elements.each do |slice|
	  		if slice.children.size < 5
	  			next
	  		end
	  		away_team = slice.children[index[:away_team]].text
	  		if away_team == "matchup"
	  			next
	  		end
	  		href = slice.children[index[:result]].child['href']
	  		game_id = href[-9..-1]
	  		if game_id == '400489736'
	  			next
	  		end
	  		unless game = Nba.find_by(game_id: game_id)
              	game = Nba.create(game_id: game_id)
            end
           
            if slice.children[index[:home_team]].children[0].children.size == 2
	  			home_team = slice.children[index[:home_team]].children[0].children[1].children[0].text
	  			home_abbr = slice.children[index[:home_team]].children[0].children[1].children[2].text
	  		elsif slice.children[index[:home_team]].children[0].children.size == 3
	  			home_team = slice.children[index[:home_team]].children[0].children[1].children[0].text + slice.children[index[:home_team]].children[0].children[2].children[0].text
	  			home_abbr = slice.children[index[:home_team]].children[0].children[2].children[2].text
	  		elsif slice.children[index[:home_team]].children[0].children.size == 1
	  			home_team = slice.children[index[:home_team]].children[0].children[0].children[0].text
	  			home_abbr = slice.children[index[:home_team]].children[0].children[0].children[2].text
	  		end

	  		if slice.children[index[:away_team]].children.size == 2
  				away_abbr = slice.children[index[:away_team]].children[1].children[2].text
	  			away_team = slice.children[index[:away_team]].children[1].children[0].text
  			elsif slice.children[index[:away_team]].children.size == 3
  				away_abbr = slice.children[index[:away_team]].children[2].children[2].text
  				away_team = slice.children[index[:away_team]].children[1].text + slice.children[index[:away_team]].children[2].children[0].text
  			elsif slice.children[index[:away_team]].children.size == 1
  				away_abbr = slice.children[index[:away_team]].children[0].children[2].text
	  			away_team = slice.children[index[:away_team]].children[0].children[0].text
  			end
        	result = slice.children[index[:result]].text

        	if home_team == "Los Angeles" ||  home_team == "LA"
		      home_team = home_abbr
		    end
		    if away_team == "Los Angeles" ||  away_team == "LA"
		      away_team = away_abbr
		    end

	  		url = "http://www.espn.com/nba/game?gameId=#{game_id}"
	  		doc = download_document(url)
			puts url
	  		element = doc.css(".game-date-time").first
	  		game_date = element.children[1]['data-date']
	  		date = DateTime.parse(game_date).in_time_zone

	  		url = "http://www.espn.com/nba/boxscore?gameId=#{game_id}"
	  		doc = download_document(url)
			puts url
	  		element = doc.css(".highlight")
	  		if element.size > 4
		  		away_value = element[0]
		  		home_value = element[2]

		  		away_mins_value = away_value.children[1].text.to_i
				away_fga_value = away_value.children[2].text
				away_fga_index = away_fga_value.index('-')
				away_fga_value = away_fga_index ? away_fga_value[away_fga_index+1..-1].to_i : 0
				away_to_value = away_value.children[11].text.to_i
				away_fta_value = away_value.children[4].text
				away_fta_index = away_fta_value.index('-')
				away_fta_value = away_fta_index ? away_fta_value[away_fta_index+1..-1].to_i : 0
				away_or_value = away_value.children[5].text.to_i
				away_poss = away_fga_value + away_to_value + (away_fta_value / 2) - away_or_value

				home_mins_value = home_value.children[1].text.to_i
				home_fga_value = home_value.children[2].text
				home_fga_index = home_fga_value.index('-')
				home_fga_value = home_fga_index ? home_fga_value[home_fga_index+1..-1].to_i : 0
				home_to_value = home_value.children[11].text.to_i
				home_fta_value = home_value.children[4].text
				home_fta_index = home_fta_value.index('-')
				home_fta_value = home_fta_index ? home_fta_value[home_fta_index+1..-1].to_i : 0
				home_or_value = home_value.children[5].text.to_i
				home_poss = home_fga_value + home_to_value + (home_fta_value / 2) - home_or_value
			end

	  		game.update(away_team: away_team, home_team: home_team, home_abbr: home_abbr, away_abbr: away_abbr, game_date: date, year: date.strftime("%Y"), date: date.strftime("%b %e"), time: date.strftime("%I:%M%p"), week: date.strftime("%a"), away_mins: away_mins_value, away_fga: away_fga_value, away_fta: away_fta_value, away_toValue: away_to_value, away_orValue: away_or_value, home_mins: home_mins_value, home_fga: home_fga_value, home_fta: home_fta_value, home_toValue: home_to_value, home_orValue: home_or_value)
	  	end
	end

	task :getScore => [:environment] do
		include Api
		puts "----------Get Score----------"

		games = Nba.where("game_date between ? and ?", Date.yesterday.beginning_of_day, Date.today.end_of_day)
		puts games.size
		games.each do |game|
			game_id = game.game_id

			url = "http://www.espn.com/nba/playbyplay?gameId=#{game_id}"
	  		doc = download_document(url)
			puts url
			elements = doc.css("#linescore tbody tr")
			if elements.size > 1
				if elements[0].children.size > 5
					away_first_quarter 	= elements[0].children[1].text.to_i
					away_second_quarter = elements[0].children[2].text.to_i
					away_third_quarter 	= elements[0].children[3].text.to_i
					away_forth_quarter 	= elements[0].children[4].text.to_i
					away_ot_quarter 	= 0

					home_first_quarter 	= elements[1].children[1].text.to_i
					home_second_quarter = elements[1].children[2].text.to_i
					home_third_quarter 	= elements[1].children[3].text.to_i
					home_forth_quarter 	= elements[1].children[4].text.to_i
					home_ot_quarter 	= 0

					if elements[0].children.size > 6
						away_ot_quarter = elements[0].children[5].text.to_i
		  				home_ot_quarter = elements[1].children[5].text.to_i
					end
				end
			else
				away_first_quarter 	= 0
				away_second_quarter = 0
				away_third_quarter 	= 0
				away_forth_quarter 	= 0
				away_ot_quarter 	= 0

				home_first_quarter 	= 0
				home_second_quarter = 0
				home_third_quarter 	= 0
				home_forth_quarter 	= 0
				home_ot_quarter 	= 0
			end
			away_score = away_first_quarter + away_second_quarter + away_third_quarter + away_forth_quarter + away_ot_quarter
			home_score = home_first_quarter + home_second_quarter + home_third_quarter + home_forth_quarter + home_ot_quarter

			game.update(away_first_quarter: away_first_quarter, home_first_quarter: home_first_quarter, away_second_quarter: away_second_quarter, home_second_quarter: home_second_quarter, away_third_quarter: away_third_quarter, home_third_quarter: home_third_quarter, away_forth_quarter: away_forth_quarter, home_forth_quarter: home_forth_quarter, away_ot_quarter: away_ot_quarter, home_ot_quarter: home_ot_quarter, away_score: away_score, home_score: home_score, total_score: home_score + away_score, first_point: home_first_quarter + home_second_quarter + away_first_quarter + away_second_quarter, second_point: home_forth_quarter + away_forth_quarter + away_third_quarter + home_third_quarter, total_point: away_first_quarter + away_second_quarter + away_third_quarter + away_forth_quarter + home_first_quarter + home_second_quarter + home_third_quarter + home_forth_quarter)
		end
	end

	task :getLinkGame => [:environment] do
		include Api
		puts "----------Get Link Games----------"

		Time.zone = 'Eastern Time (US & Canada)'

		games = Nba.where("game_date between ? and ?", (Date.today - 10.days).beginning_of_day, (Date.today + 5.days).end_of_day)
		puts games.size
		games.each do |game|
			home_team = game.home_team
			away_team = game.away_team
			game_date = game.game_date
			puts DateTime.parse(game_date).in_time_zone.to_date

			away_last_game = ""
			away_team_prev = Nba.where("home_team = ? AND game_date < ?", away_team, game_date).or(Nba.where("away_team = ? AND game_date < ?", away_team, game_date)).order(:game_date).last
			if away_team_prev
				away_last_game = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(away_team_prev.game_date).in_time_zone.to_date ).to_i - 1
			end

			away_next_game = ""
			away_team_next = Nba.where("home_team = ? AND game_date > ?", away_team, game_date).or(Nba.where("away_team = ? AND game_date > ?", away_team, game_date)).order(:game_date).first
			if away_team_next
				away_next_game = (DateTime.parse(away_team_next.game_date).in_time_zone.to_date  - DateTime.parse(game_date).in_time_zone.to_date ).to_i - 1
			end

			home_last_game = ""
			home_last_fly = ""
			home_team_prev = Nba.where("home_team = ? AND game_date < ?", home_team, game_date).or(Nba.where("away_team = ? AND game_date < ?", home_team, game_date)).order(:game_date).last
			if home_team_prev
				home_last_game = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(home_team_prev.game_date).in_time_zone.to_date ).to_i - 1
				if home_team_prev.home_team == home_team
					home_last_fly = "NO"
				else
					home_last_fly = "YES"
				end
			end

			home_next_game = ""
			home_next_fly = ""
			home_team_next = Nba.where("home_team = ? AND game_date > ?", home_team, game_date).or(Nba.where("away_team = ? AND game_date > ?", home_team, game_date)).order(:game_date).first
			if home_team_next
				home_next_game = (DateTime.parse(home_team_next.game_date).in_time_zone.to_date  - DateTime.parse(game_date).in_time_zone.to_date ).to_i - 1
				if home_team_next.home_team == home_team
					home_next_fly = "NO"
				else
					home_next_fly = "YES"
				end
			end
			game.update(away_last_game: away_last_game, away_next_game: away_next_game, home_last_game: home_last_game, home_next_game: home_next_game, home_next_fly: home_next_fly, home_last_fly: home_last_fly)
		end
	end

	task :getFirstLines => [:environment] do
		include Api
		games = Nba.all
		puts "----------Get First Lines----------"

		index_date = Date.yesterday
		while index_date <= Date.tomorrow  do
			game_day = index_date.strftime("%Y%m%d")
			puts game_day
			url = "https://www.sportsbookreview.com/betting-odds/nba-basketball/1st-half/?date=#{game_day}"
			doc = download_document(url)
			elements = doc.css(".event-holder")
			elements.each do |element|
				if element.children[0].children[1].children.size > 2 && element.children[0].children[1].children[2].children[1].children.size == 1
					next
				end
				if element.children[0].children[5].children.size < 5
					next
				end

				if element.children[0].children[3].children.size < 3
					next
				end

				score_element = element.children[0].children[9]

				if score_element.children[1].text == ""
					score_element = element.children[0].children[13]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[11]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[12]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[10]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[17]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[18]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[14]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[15]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[16]
				end

				home_name 		= element.children[0].children[5].children[1].text
				away_name 		= element.children[0].children[5].children[0].text
				home_number 	= element.children[0].children[3].children[2].text
				away_number 	= element.children[0].children[3].children[1].text
				closer 			= score_element.children[1].text
				opener 			= element.children[0].children[7].children[1].text
				
				game_time = element.children[0].children[4].text
				ind = game_time.index(":")
				hour = ind ? game_time[0..ind-1].to_i : 0
				min = ind ? game_time[ind+1..ind+3].to_i : 0
				ap = game_time[-1]
				if ap == "p" && hour != 12
					hour = hour + 12
				end
				if ap == "a" && hour == 12
					hour = 24
				end

				if @nba_nicknames[home_name]
			      home_name = @nba_nicknames[home_name]
			    end
			    if @nba_nicknames[away_name]
			      away_name = @nba_nicknames[away_name]
			    end
				date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 5.hours +  hour.hours

				line_one = opener.index(" ")
				opener_side = line_one ? opener[0..line_one] : ""
				opener_total = line_one ? opener[line_one+2..-1] : ""
				line_two = closer.index(" ")
				closer_side = line_two ? closer[0..line_two] : ""
				closer_total = line_two ? closer[line_two+2..-1] : ""

				matched = games.select{|field| ((field.home_team.include?(home_name) && field.away_team.include?(away_name)) || (field.home_team.include?(away_name) && field.away_team.include?(home_name))) && (date == field.game_date) }
				if matched.size > 0
					update_game = matched.first
					if opener_side.include?('½')
						if opener_side[0] == '-'
							opener_side = opener_side[0..-1].to_f - 0.5
						elsif
							opener_side = opener_side[0..-1].to_f + 0.5
						end
					else
						opener_side = opener_side.to_f
					end
					if closer_side.include?('½')
						if closer_side[0] == '-'
							closer_side = closer_side[0..-1].to_f - 0.5
						elsif
							closer_side = closer_side[0..-1].to_f + 0.5
						end
					else
						closer_side = closer_side.to_f
					end
					if opener_total.include?('½')
						opener_total = opener_total[0..-1].to_f + 0.5
					else
						opener_total = opener_total.to_f
					end
					if closer_total.include?('½')
						closer_total = closer_total[0..-1].to_f + 0.5
					else
						closer_total = closer_total.to_f
					end
					update_game.update(first_opener_side: opener_side, first_closer_side: closer_side, first_opener_total: opener_total, first_closer_total: closer_total)
					if update_game.home_team.include?(home_name)
						update_game.update(home_number: home_number, away_number: away_number)
					else
						update_game.update(away_number: home_number, home_number: away_number)
					end
				end
			end
			index_date = index_date + 1.days
		end
	end

	task :getSecondLines => [:environment] do
		include Api
		games = Nba.all
		puts "----------Get Second Lines----------"

		index_date = Date.new(2013, 11, 28)
		while index_date <= Date.tomorrow  do
			game_day = index_date.strftime("%Y%m%d")
			puts game_day
			url = "https://www.sportsbookreview.com/betting-odds/nba-basketball/2nd-half/?date=#{game_day}"
			doc = download_document(url)
			elements = doc.css(".event-holder")
			elements.each do |element|
				if element.children[0].children[1].children.size > 2 && element.children[0].children[1].children[2].children[1].children.size == 1
					next
				end
				if element.children[0].children[5].children.size < 5
					next
				end
				score_element = element.children[0].children[9]

				if score_element.children[1].text == ""
					score_element = element.children[0].children[13]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[11]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[12]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[10]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[17]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[18]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[14]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[15]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[16]
				end

				home_name 		= element.children[0].children[5].children[1].text
				away_name 		= element.children[0].children[5].children[0].text
				closer 			= score_element.children[1].text
				opener 			= element.children[0].children[7].children[1].text
				
				game_time = element.children[0].children[4].text
				ind = game_time.index(":")
				hour = ind ? game_time[0..ind-1].to_i : 0
				min = ind ? game_time[ind+1..ind+3].to_i : 0
				ap = game_time[-1]
				if ap == "p" && hour != 12
					hour = hour + 12
				end
				if ap == "a" && hour == 12
					hour = 24
				end

				if @nba_nicknames[home_name]
			      home_name = @nba_nicknames[home_name]
			    end
			    if @nba_nicknames[away_name]
			      away_name = @nba_nicknames[away_name]
			    end
				date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 5.hours +  hour.hours

				line_one = opener.index(" ")
				opener_side = line_one ? opener[0..line_one] : ""
				opener_total = line_one ? opener[line_one+2..-1] : ""
				line_two = closer.index(" ")
				closer_side = line_two ? closer[0..line_two] : ""
				closer_total = line_two ? closer[line_two+2..-1] : ""

				matched = games.select{|field| ((field.home_team.include?(home_name) && field.away_team.include?(away_name)) || (field.home_team.include?(away_name) && field.away_team.include?(home_name))) && (date == field.game_date) }
				if matched.size > 0
					update_game = matched.first
					if opener_side.include?('½')
						if opener_side[0] == '-'
							opener_side = opener_side[0..-1].to_f - 0.5
						elsif
							opener_side = opener_side[0..-1].to_f + 0.5
						end
					else
						opener_side = opener_side.to_f
					end
					if closer_side.include?('½')
						if closer_side[0] == '-'
							closer_side = closer_side[0..-1].to_f - 0.5
						elsif
							closer_side = closer_side[0..-1].to_f + 0.5
						end
					else
						closer_side = closer_side.to_f
					end
					if opener_total.include?('½')
						opener_total = opener_total[0..-1].to_f + 0.5
					else
						opener_total = opener_total.to_f
					end
					if closer_total.include?('½')
						closer_total = closer_total[0..-1].to_f + 0.5
					else
						closer_total = closer_total.to_f
					end
					update_game.update(second_opener_side: opener_side, second_closer_side: closer_side, second_opener_total: opener_total, second_closer_total: closer_total)
				end
			end
			index_date = index_date + 1.days
		end
	end

	task :getFullLines => [:environment] do
		include Api
		games = Nba.all
		puts "----------Get Full Lines----------"

		index_date = Date.new(2009, 12, 30)
		while index_date <= Date.tomorrow  do
			game_day = index_date.strftime("%Y%m%d")
			puts game_day
			url = "https://www.sportsbookreview.com/betting-odds/nba-basketball/?date=#{game_day}"
			doc = download_document(url)
			elements = doc.css(".event-holder")
			elements.each do |element|
				if element.children[0].children[1].children.size > 2 && element.children[0].children[1].children[2].children[1].children.size == 1
					next
				end
				if element.children[0].children[5].children.size < 5
					next
				end
				score_element = element.children[0].children[9]

				if score_element.children[1].text == ""
					score_element = element.children[0].children[13]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[11]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[12]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[10]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[17]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[18]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[14]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[15]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[16]
				end

				home_name 		= element.children[0].children[5].children[1].text
				away_name 		= element.children[0].children[5].children[0].text
				closer 			= score_element.children[1].text
				opener 			= element.children[0].children[7].children[1].text
				
				game_time = element.children[0].children[4].text
				ind = game_time.index(":")
				hour = ind ? game_time[0..ind-1].to_i : 0
				min = ind ? game_time[ind+1..ind+3].to_i : 0
				ap = game_time[-1]
				if ap == "p" && hour != 12
					hour = hour + 12
				end
				if ap == "a" && hour == 12
					hour = 24
				end

				if @nba_nicknames[home_name]
			      home_name = @nba_nicknames[home_name]
			    end
			    if @nba_nicknames[away_name]
			      away_name = @nba_nicknames[away_name]
			    end
				date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 5.hours +  hour.hours

				line_one = opener.index(" ")
				opener_side = line_one ? opener[0..line_one] : ""
				opener_total = line_one ? opener[line_one+2..-1] : ""
				line_two = closer.index(" ")
				closer_side = line_two ? closer[0..line_two] : ""
				closer_total = line_two ? closer[line_two+2..-1] : ""

				matched = games.select{|field| ((field.home_team.include?(home_name) && field.away_team.include?(away_name)) || (field.home_team.include?(away_name) && field.away_team.include?(home_name))) && (date == field.game_date) }
				if matched.size > 0
					update_game = matched.first
					if opener_side.include?('½')
						if opener_side[0] == '-'
							opener_side = opener_side[0..-1].to_f - 0.5
						elsif
							opener_side = opener_side[0..-1].to_f + 0.5
						end
					else
						opener_side = opener_side.to_f
					end
					if closer_side.include?('½')
						if closer_side[0] == '-'
							closer_side = closer_side[0..-1].to_f - 0.5
						elsif
							closer_side = closer_side[0..-1].to_f + 0.5
						end
					else
						closer_side = closer_side.to_f
					end
					if opener_total.include?('½')
						opener_total = opener_total[0..-1].to_f + 0.5
					else
						opener_total = opener_total.to_f
					end
					if closer_total.include?('½')
						closer_total = closer_total[0..-1].to_f + 0.5
					else
						closer_total = closer_total.to_f
					end
					update_game.update(full_opener_side: opener_side, full_closer_side: closer_side, full_opener_total: opener_total, full_closer_total: closer_total)
				end
			end
			index_date = index_date + 1.days
		end
	end

	task :test => [:environment] do
		include Api

			url = "https://www.sportsbookreview.com/betting-odds/nba-basketball/"
			doc = download_document(url)
			elements = doc.css(".event-holder")
			elements.each do |element|
				if element.children[0].children[1].children.size > 2 && element.children[0].children[1].children[2].children[1].children.size == 1
					next
				end
				if element.children[0].children[5].children.size < 5
					next
				end
				score_element = element.children[0].children[9]

				if score_element.children[1].text == ""
					score_element = element.children[0].children[13]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[11]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[12]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[10]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[17]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[18]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[14]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[15]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[16]
				end

				home_name 		= element.children[0].children[5].children[1].text
				away_name 		= element.children[0].children[5].children[0].text
				closer		 	= score_element.children[1].text
				opener		 	= element.children[0].children[7].children[1].text
				
				game_time = element.children[0].children[4].text
				ind = game_time.index(":")
				hour = ind ? game_time[0..ind-1].to_i : 0
				min = ind ? game_time[ind+1..ind+3].to_i : 0
				ap = game_time[-1]
				if ap == "p" && hour != 12
					hour = hour + 12
				end
				if ap == "a" && hour == 12
					hour = 24
				end

				if @nba_nicknames[home_name]
			      home_name = @nba_nicknames[home_name]
			    end
			    if @nba_nicknames[away_name]
			      away_name = @nba_nicknames[away_name]
			    end

				line_one = opener.index(" ")
				opener_side = line_one ? opener[0..line_one] : ""
				opener_total = line_one ? opener[line_one+2..-1] : ""
				line_two = closer.index(" ")
				closer_side = line_two ? closer[0..line_two] : ""
				closer_total = line_two ? closer[line_two+2..-1] : ""
				puts opener_side
				puts closer_side
				puts opener_total
				puts closer_total
			end
	end

	task :getPlayer => [:environment] do
		include Api
		puts "----------Get Players----------"
		games = Nba.where("game_date between ? and ?", (Date.today - 5.days).beginning_of_day, Date.today.end_of_day)
		puts games.size
		games.each do |game|
			game_id = game.game_id
			puts game_id
			url = "http://www.espn.com/nba/boxscore?gameId=#{game_id}"
			doc = download_document(url)

			away_players = doc.css('#gamepackage-boxscore-module .gamepackage-away-wrap tbody tr')
			team_abbr = 0
			end_index = away_players.size - 2
			(0..end_index).each_with_index do |element, index|
				slice = away_players[element]
				if slice.children.size < 15
					next
				end

				if slice.children[0].children.size > 1
					player_name = slice.children[0].children[0].children[0].text
					link = slice.children[0].children[0]['href']
					puts link
					page = download_document(link)
					height = page.css(".general-info")[0].children[1].text
				else
					player_name = slice.children[0].text
					link = ""
					height = 0
				end
				position = ""
				mins_value = slice.children[1].text.to_i
				fga_value = slice.children[2].text
				fga_index = fga_value.index('-')
				fga_value = fga_index ? fga_value[fga_index+1..-1].to_i : 0
				to_value = slice.children[11].text.to_i
				fta_value = slice.children[4].text
				fta_index = fta_value.index('-')
				fta_value = fta_index ? fta_value[fta_index+1..-1].to_i : 0
				or_value = slice.children[5].text.to_i
				poss = fga_value + to_value + (fta_value * 0.44) - or_value
				if slice.children[0].children.size > 1
					position = slice.children[0].children[1].text
				end
				unless player = game.players.find_by(player_name: player_name, team_abbr: team_abbr)
		           	player = game.players.create(player_name: player_name, team_abbr: team_abbr)
	            end
	            player.update(position: position, state: index + 1, poss: poss, mins: mins_value, fga: fga_value, fta:fta_value, toValue: to_value, orValue: or_value, height: height, link: link, game_date: game.game_date )
			end

			home_players = doc.css('#gamepackage-boxscore-module .gamepackage-home-wrap tbody tr')
			team_abbr = 1
			end_index = home_players.size - 2
			(0..end_index).each_with_index do |element, index|
				slice = home_players[element]
				if slice.children.size < 15
					next
				end
				if slice.children[0].children.size > 1
					player_name = slice.children[0].children[0].children[0].text
					link = slice.children[0].children[0]['href']
					puts link
					page = download_document(link)
					height = page.css(".general-info")[0].children[1].text
				else
					player_name = slice.children[0].text
					link = ""
					height = 0
				end
				position = ""
				mins_value = slice.children[1].text.to_i
				fga_value = slice.children[2].text
				fga_index = fga_value.index('-')
				fga_value = fga_index ? fga_value[fga_index+1..-1].to_i : 0
				to_value = slice.children[11].text.to_i
				fta_value = slice.children[4].text
				fta_index = fta_value.index('-')
				fta_value = fta_index ? fta_value[fta_index+1..-1].to_i : 0
				or_value = slice.children[5].text.to_i
				poss = fga_value + to_value + (fta_value *0.44) - or_value
				if slice.children[0].children.size > 1
					position = slice.children[0].children[1].text
				end
				unless player = game.players.find_by(player_name: player_name, team_abbr: team_abbr)
		           	player = game.players.create(player_name: player_name, team_abbr: team_abbr)
	            end
	            player.update(position: position, state: index + 1, poss: poss, mins: mins_value, fga: fga_value, fta:fta_value, toValue: to_value, orValue: or_value, height: height, link: link, game_date: game.game_date  )
			end
		end
	end

	task :gettg => [:environment] do
		include Api
		@basket_abbr.each do |team_abbr|
			url = "https://www.basketball-reference.com/teams/#{team_abbr}/"
			puts url
			doc = download_document(url)
			links = doc.css('.stats_table tbody tr th')
			links.each_with_index do |link, index|
				href = "https://www.basketball-reference.com#{link.child['href']}"
				puts href
				year = href[-9..-6].to_i
				doc = download_document(href)
				doc.xpath('//comment()').each { |comment| comment.replace(comment.text) }
				players = doc.css('#div_per_poss tbody tr')
				players.each do |player|
					player_name = player.children[1].children[0].text
					player_index = player_name.rindex(' ')
					player_name = player_index ? player_name[0] + ". " + player_name[player_index+1..-1] : ""
					ortg = player.children[28].text
					drtg = player.children[29].text
					unless player_element = Tg.find_by(player_name: player_name, team_abbr: team_abbr, year: year)
			           	player_element = Tg.create(player_name: player_name, team_abbr: team_abbr, year: year)
		            end
		            player_element.update(ortg: ortg, drtg: drtg)
				end
				if index == 18
					break
				end
				break
			end
		end
	end

	task :getUpdatePoss => [:environment] do
		include Api
		Time.zone = 'Eastern Time (US & Canada)'
		games = Nba.where("game_date between ? and ?", (Date.today - 5.days).beginning_of_day, Time.now-5.hours)
		games.each do |game|
			players = game.players.where("player_name <> 'TEAM'")
			players.each do |player|
				possession = []
				sum_mins = 0
				sum_poss = 0
				team_poss = 0
				count = 0
				mins_min = 100
				mins_max = 0
				last_players = Player.where("game_date >= ? AND game_date <= ? AND player_name = ?", Date.new(2017, 10 ,20), player.game_date, player.player_name).or(Player.where("game_date <= ? AND player_name = ?", Date.new(2017, 6 ,18), player.player_name)).order('game_date DESC')
				last_players.each do |last_player|
					if count == 10
						break
					end
					if last_player.mins > 10
						possession.push(last_player.nba_id)
						sum_poss = sum_poss + last_player.poss
						sum_mins = sum_mins + last_player.mins
						if mins_min > last_player.mins
							mins_min = last_player.mins
						end
						if mins_max < last_player.mins
							mins_max = last_player.mins
						end
						last_team = Player.where("nba_id = ? AND team_abbr = ? AND player_name = ?",last_player.nba_id, last_player.team_abbr, "TEAM")
						team_poss = team_poss + last_team.first.poss
						count = count + 1
					end
				end
				sum_mins = sum_mins - mins_min - mins_max
				player.update(sum_poss: sum_poss, team_poss: team_poss, possession: possession.join(","), sum_mins: sum_mins)
			end
		end
	end

	task :setDate => [:environment] do
		games = Nba.where("game_date between ? and ?", (Date.today - 2.years).beginning_of_day, Time.now-5.hours)
		games.each do |game|
			players= game.players.all
			players.each do |player|
				player.update(game_date: game.game_date)
			end
		end
	end

	task :getUpdateTG => [:environment] do
		include Api
		games = Nba.where("game_date between ? and ?", (Date.today - 5.days).beginning_of_day, Time.now-5.hours)
		puts games.size
		games.each do |game|
			players = game.players.all
			players.each do |player|
				if player.player_name == "TEAM"
					next
				end
		        team_abbr = game.home_abbr
		        if player.team_abbr == 0
					team_abbr = game.away_abbr
				end
		        if @team_nicknames[team_abbr]
					team_abbr = @team_nicknames[team_abbr]
					
					player_name = player.player_name

					player_name_index = player_name.index(" Jr.")
					player_name = player_name_index ? player_name[0..player_name_index-1] : player_name

					player_name_index = player_name.index(" III")
					player_name = player_name_index ? player_name[0..player_name_index-1] : player_name

					if @player_name[player_name]
						player_name = @player_name[player_name]
					end
					
					ortg = ""
					drtg = ""
					last_ortg = 0
					last_drtg = 0
					this_ortg = 0
					this_drtg = 0
					if player_element = Tg.find_by(player_name: player_name, year: 2017)
						last_ortg = player_element.ortg
						last_ortg = 0 unless last_ortg
						last_drtg = player_element.drtg
						last_drtg = 0 unless last_drtg
					end
					if player_element = Tg.find_by(player_name: player_name, year: 2018)
						this_ortg = player_element.ortg
						this_drtg = player_element.drtg
						this_ortg = 0 unless this_ortg
						this_drtg = 0 unless this_drtg
					end
					url = player.link
					url = url.gsub(/player/,'player/stats')
					puts url
					page = download_document(url)
					trs = page.css(".mod-player-stats table .oddrow, .mod-player-stats table .evenrow")
					if trs.length != 3
						last_element = trs[trs.length/3 - 2]
					else
						last_element = trs[trs.length/3 - 1]
					end
					this_element = trs[trs.length/3 - 1]

					last_count = last_element.children[2].text.to_i
					this_count = this_element.children[2].text.to_i

					if this_ortg == 0
						this_count = 0
					end

					if last_ortg == 0
						last_count = 0
					end

					ortg = 0
					drtg = 0

					if last_count + this_count != 0
						ortg = (last_count * last_ortg + this_count * this_ortg) / (last_count + this_count)
						drtg = (last_count * last_drtg + this_count * this_drtg) / (last_count + this_count)
					end
					player.update(ortg: ortg, drtg: drtg)
				end
			end
		end
	end

	task :getUpdateRate => [:environment] do
		games = Nba.where("game_date between ? and ?", (Date.today - 5.days).beginning_of_day, Time.now-5.hours)
		puts games.size
		games.each do |game|
			away_players = game.players.where("team_abbr = 0 AND mins > 10")
		    home_players = game.players.where("team_abbr = 1 AND mins > 10")
		 	away_total_poss = 0
		    away_players.each_with_index do |player, index| 
		    	if player.player_name == "TEAM"
		    		next
		    	end
		    	if player.possession
		            count = player.possession.scan(/,/).count + 1
		        end
		    	count = 1
		        if count < 10
		        	next
		        end
		        away_total_poss = away_total_poss + (100 * player.sum_poss.to_f / player.team_poss)
		    end

		    away_players.each_with_index do |player, index| 
		    	if player.player_name == "TEAM"
		    		next
		    	end
		    	if player.possession
		            count = player.possession.scan(/,/).count + 1
		        end
		    	count = 1
		        if count < 10
		        	next
		        end
		    	player.update(prorate: 100 * (100 * player.sum_poss.to_f/player.team_poss) / away_total_poss)
		    end

		    home_total_poss = 0
		    home_players.each_with_index do |player, index| 
		    	if player.player_name == "TEAM"
		    		next
		    	end
		    	if player.possession
		            count = player.possession.scan(/,/).count + 1
		        end
		    	count = 1
		        if count < 10
		        	next
		        end
		        home_total_poss = home_total_poss + (100 * player.sum_poss.to_f/player.team_poss)
		    end

		    home_players.each_with_index do |player, index|
		    	if player.player_name == "TEAM"
		    		next
		    	end
		    	count = 1
		    	if player.possession
		            count = player.possession.scan(/,/).count + 1
		        end
		        if count < 10
		        	next
		        end
		    	player.update(prorate: 100 * (100 * player.sum_poss.to_f/player.team_poss) / home_total_poss)
		    end
		end
	end

	task :atest => :environment do
		include Api
		player = Player.find_by(player_name: "T. Cavanaugh", nba_id: 24028)
		player_name = "T. Cavanaugh"

		ortg = ""
					drtg = ""
					last_ortg = 0
					last_drtg = 0
					this_ortg = 0
					this_drtg = 0
					if player_element = Tg.find_by(player_name: player_name, year: 2017)
						last_ortg = player_element.ortg
						last_ortg = 0 unless last_ortg
						last_drtg = player_element.drtg
						last_drtg = 0 unless last_drtg
					end
					if player_element = Tg.find_by(player_name: player_name, year: 2018)
						this_ortg = player_element.ortg
						this_drtg = player_element.drtg
						this_ortg = 0 unless this_ortg
						this_drtg = 0 unless this_drtg
					end
					url = player.link
					url = url.gsub(/player/,'player/stats')
					puts url
					page = download_document(url)
					trs = page.css(".mod-player-stats table .oddrow, .mod-player-stats table .evenrow")
					if trs.length != 3
						last_element = trs[trs.length/3 - 2]
					else
						last_element = trs[trs.length/3 - 1]
					end
					this_element = trs[trs.length/3 - 1]

					last_count = last_element.children[2].text.to_i
					this_count = this_element.children[2].text.to_i
					puts last_count
					puts this_count

					last_fga = last_element.children[5].text
					this_fga = this_element.children[5].text

					last_fga_index = last_fga.index("-")
					last_fga = last_fga_index ? last_fga[last_fga_index+1..-1] : ""
					this_fga_index = this_fga.index("-")
					this_fga = this_fga_index ? this_fga[this_fga_index+1..-1] : ""
					puts last_fga
					puts this_fga

					last_fta = last_element.children[9].text
					this_fta = this_element.children[9].text

					last_fta_index = last_fta.index("-")
					last_fta = last_fta_index ? last_fta[last_fta_index+1..-1] : ""

					this_fta_index = this_fta.index("-")
					this_fta = this_fta_index ? this_fta[this_fta_index+1..-1] : ""
					puts last_fta
					puts this_fta

					last_or = last_element.children[11].text
					this_or = this_element.children[11].text

					last_to = last_element.children[18].text
					this_to = this_element.children[18].text

					last_poss = last_fga.to_f + (last_fta.to_f * 0.44) + last_to.to_f - last_or.to_f
					this_poss = this_fga.to_f + (this_fta.to_f * 0.44) + this_to.to_f - this_or.to_f
					puts last_poss
					puts this_poss

					if this_ortg == 0
						this_count = 0
					end

					if last_ortg == 0
						last_count = 0
					end


					ortg = (last_count * last_poss * last_ortg + this_count * this_poss * this_ortg) / (last_count * last_poss + this_count * this_poss)
					drtg = (last_count * last_poss * last_drtg + this_count * this_poss * this_drtg) / (last_count * last_poss + this_count * this_poss)
					puts ortg
					puts drtg
	end

		@basket_abbr = [
		'ATL',
		'BOS',
		'CHA',
		'CHI',
		'CLE',
		'DAL',
		'DEN',
		'DET',
		'HOU',
		'IND',
		'LAC',
		'LAL',
		'MEM',
		'MIA',
		'MIL',
		'MIN',
		'OKC',
		'ORL',
		'PHI',
		'POR',
		'SAC',
		'TOR',
		'NJN',
		'GSW',
		'NOH',
		'NYK',
		'PHO',
		'SAS',
		'UTA',
		'WAS'
	]

	@team_nicknames = {
		'ATL' => 'ATL',
		'BOS' => 'BOS',
		'CHA' => 'CHA',
		'CHI' => 'CHI',
		'CLE' => 'CLE',
		'DAL' => 'DAL',
		'DEN' => 'DEN',
		'DET' => 'DET',
		'HOU' => 'HOU',
		'IND' => 'IND',
		'LAC' => 'LAC',
		'LAL' => 'LAL',
		'MEM' => 'MEM',
		'MIA' => 'MIA',
		'MIL' => 'MIL',
		'MIN' => 'MIN',
		'OKC' => 'OKC',
		'ORL' => 'ORL',
		'PHI' => 'PHI',
		'POR' => 'POR',
		'SAC' => 'SAC',
		'TOR' => 'TOR',
		'BKN' => 'NJN',
		'NJ' => 'NJN',
		'GS' => 'GSW',
		'NO' => 'NOH',
		'NY' => 'NYK',
		'PHX' => 'PHO',
		'SA' => 'SAS',
		'UTAH' => 'UTA',
		'WSH' => 'WAS',
		'SEA' => 'OKC',
		'VAN' => 'MEM'
	}

	@nba_nicknames = {
		"L.A. Lakers" => "LAL",
		"L.A. Clippers" => "LAC"
	}

	@player_name = {
		"T. Prince" => "T. Waller-Prince",
		"T.J. McConnell" => "T. McConnell",
		"J.J. Barea" => "J. Barea",
		"T.J. Leaf" => "T. Leaf"
	}
end