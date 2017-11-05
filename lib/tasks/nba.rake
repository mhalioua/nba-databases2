namespace :nba do


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

		Rake::Task["nba:getPlayer"].invoke
		Rake::Task["nba:getPlayer"].reenable

		Rake::Task["nba:getUpdateTG"].invoke
		Rake::Task["nba:getUpdateTG"].reenable
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
	  		game.update(away_team: away_team, home_team: home_team, home_abbr: home_abbr, away_abbr: away_abbr, game_date: date, year: date.strftime("%Y"), date: date.strftime("%b %e"), time: date.strftime("%I:%M%p"), week: date.strftime("%a"))
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
			url = "https://www.sportsbookreview.com/betting-odds/nba-basketball/merged/1st-half/?date=#{game_day}"
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
				home_pinnacle 	= score_element.children[1].text
				away_pinnacle 	= score_element.children[0].text
				
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
				date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 4.hours +  hour.hours

				line_one = home_pinnacle.index(" ")
				line_one = line_one ? home_pinnacle[0..line_one] : ""
				line_two = away_pinnacle.index(" ")
				line_two = line_two ? away_pinnacle[0..line_two] : ""
				if line_one == ""
					first_line = line_two
					first_side = ""
				elsif line_one[0] == "-" || line_one[0] == "P"
					first_line = line_two
					first_side = line_one[1..-1]
					if line_one[0] == "P"
						first_side = line_one
					end
				elsif line_two == ""
					first_line = line_one
					first_side = ""
				else
					first_line = line_one
					first_side = line_two[1..-1]
					if line_two[0] == "P"
						first_side = line_two
					end
				end

				matched = games.select{|field| ((field.home_team.include?(home_name) && field.away_team.include?(away_name)) || (field.home_team.include?(away_name) && field.away_team.include?(home_name))) && (date == field.game_date) }
				if matched.size > 0
					update_game = matched.first
					if first_line.include?('½')
						first_line = first_line[0..-1].to_f + 0.5
					else
						first_line = first_line.to_f
					end
					if first_side.include?('½')
						first_side = first_side[0..-1].to_f + 0.5
					else
						first_side = first_side.to_f
					end
					update_game.update(first_line: first_line, first_side: first_side)
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

		index_date = Date.yesterday
		while index_date <= Date.tomorrow  do
			game_day = index_date.strftime("%Y%m%d")
			puts game_day
			url = "https://www.sportsbookreview.com/betting-odds/nba-basketball/merged/2nd-half/?date=#{game_day}"
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
				home_pinnacle 	= score_element.children[1].text
				away_pinnacle 	= score_element.children[0].text
				
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
				date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 4.hours +  hour.hours

				line_one = home_pinnacle.index(" ")
				line_one = line_one ? home_pinnacle[0..line_one] : ""
				line_two = away_pinnacle.index(" ")
				line_two = line_two ? away_pinnacle[0..line_two] : ""
				if line_one == ""
					first_line = line_two
					first_side = ""
				elsif line_one[0] == "-" || line_one[0] == "P"
					first_line = line_two
					first_side = line_one[1..-1]
					if line_one[0] == "P"
						first_side = line_one
					end
				elsif line_two == ""
					first_line = line_one
					first_side = ""
				else
					first_line = line_one
					first_side = line_two[1..-1]
					if line_two[0] == "P"
						first_side = line_two
					end
				end

				matched = games.select{|field| ((field.home_team.include?(home_name) && field.away_team.include?(away_name)) || (field.home_team.include?(away_name) && field.away_team.include?(home_name))) && (date == field.game_date) }
				if matched.size > 0
					update_game = matched.first
					if first_line.include?('½')
						first_line = first_line[0..-1].to_f + 0.5
					else
						first_line = first_line.to_f
					end
					if first_side.include?('½')
						first_side = first_side[0..-1].to_f + 0.5
					else
						first_side = first_side.to_f
					end
					update_game.update(second_line: first_line, second_side: first_side)
				end
			end
			index_date = index_date + 1.days
		end
	end

	task :getFullLines => [:environment] do
		include Api
		games = Nba.all
		puts "----------Get Full Lines----------"

		index_date = Date.yesterday
		while index_date <= Date.tomorrow  do
			game_day = index_date.strftime("%Y%m%d")
			puts game_day
			url = "https://www.sportsbookreview.com/betting-odds/nba-basketball/merged/?date=#{game_day}"
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
				home_pinnacle 	= score_element.children[1].text
				away_pinnacle 	= score_element.children[0].text
				
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
				date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 4.hours +  hour.hours

				line_one = home_pinnacle.index(" ")
				line_one = line_one ? home_pinnacle[0..line_one] : ""
				line_two = away_pinnacle.index(" ")
				line_two = line_two ? away_pinnacle[0..line_two] : ""
				if line_one == ""
					first_line = line_two
					first_side = ""
				elsif line_one[0] == "-" || line_one[0] == "P"
					first_line = line_two
					first_side = line_one[1..-1]
					if line_one[0] == "P"
						first_side = line_one
					end
				elsif line_two == ""
					first_line = line_one
					first_side = ""
				else
					first_line = line_one
					first_side = line_two[1..-1]
					if line_two[0] == "P"
						first_side = line_two
					end
				end

				matched = games.select{|field| ((field.home_team.include?(home_name) && field.away_team.include?(away_name)) || (field.home_team.include?(away_name) && field.away_team.include?(home_name))) && (date == field.game_date) }
				if matched.size > 0
					update_game = matched.first
					if first_line.include?('½')
						first_line = first_line[0..-1].to_f + 0.5
					else
						first_line = first_line.to_f
					end
					if first_side.include?('½')
						first_side = first_side[0..-1].to_f + 0.5
					else
						first_side = first_side.to_f
					end
					update_game.update(full_line: first_line, full_side: first_side)
				end
			end
			index_date = index_date + 1.days
		end
	end

	task :test => [:environment] do
		include Api
		games = Nba.all

		index_date = Date.new(2006, 10, 30)
		while index_date <= Date.tomorrow  do
			game_day = index_date.strftime("%Y%m%d")
			puts game_day
			url = "https://www.sportsbookreview.com/betting-odds/nba-basketball/merged/1st-half/?date=#{game_day}"
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
				home_pinnacle 	= score_element.children[1].text
				away_pinnacle 	= score_element.children[0].text
				
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
				date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 4.hours +  hour.hours

				line_one = home_pinnacle.index(" ")
				line_one = line_one ? home_pinnacle[0..line_one] : ""
				line_two = away_pinnacle.index(" ")
				line_two = line_two ? away_pinnacle[0..line_two] : ""
				if line_one == ""
					first_line = line_two
					first_side = ""
				elsif line_one[0] == "-" || line_one[0] == "P"
					first_line = line_two
					first_side = line_one[1..-1]
					if line_one[0] == "P"
						first_side = line_one
					end
				elsif line_two == ""
					first_line = line_one
					first_side = ""
				else
					first_line = line_one
					first_side = line_two[1..-1]
					if line_two[0] == "P"
						first_side = line_two
					end
				end

				matched = games.select{|field| ((field.home_team.include?(home_name) && field.away_team.include?(away_name)) || (field.home_team.include?(away_name) && field.away_team.include?(home_name))) && (date == field.game_date) }
				if matched.size > 0
					update_game = matched.first
					if first_line.include?('½')
						first_line = first_line[0..-1].to_f + 0.5
					else
						first_line = first_line.to_f
					end
					if first_side.include?('½')
						first_side = first_side[0..-1].to_f + 0.5
					else
						first_side = first_side.to_f
					end
					update_game.update(first_line: first_line, first_side: first_side)
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

	task :getPlayer => [:environment] do
		include Api
		puts "----------Get Players----------"
		games = Nba.where("game_date between ? and ?", (Date.today - 3.days).beginning_of_day, Date.today.end_of_day)
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
				else
					player_name = slice.children[0].text
				end
				position = ""
				fga_value = slice.children[2].text
				fga_index = fga_value.index('-')
				fga_value = fga_index ? fga_value[fga_index+1..-1].to_i : 0
				to_value = slice.children[11].text.to_i
				fta_value = slice.children[4].text
				fta_index = fta_value.index('-')
				fta_value = fta_index ? fta_value[fta_index+1..-1].to_i : 0
				or_value = slice.children[5].text.to_i
				poss = fga_value + to_value + (fta_value / 2) - or_value
				if slice.children[0].children.size > 1
					position = slice.children[0].children[1].text
				end
				unless player = game.players.find_by(player_name: player_name, team_abbr: team_abbr)
		           	player = game.players.create(player_name: player_name, team_abbr: team_abbr)
	            end
	            player.update(position: position, state: index + 1, poss: poss)
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
				else
					player_name = slice.children[0].text
				end
				position = ""
				fga_value = slice.children[2].text
				fga_index = fga_value.index('-')
				fga_value = fga_index ? fga_value[fga_index+1..-1].to_i : 0
				to_value = slice.children[11].text.to_i
				fta_value = slice.children[4].text
				fta_index = fta_value.index('-')
				fta_value = fta_index ? fta_value[fta_index+1..-1].to_i : 0
				or_value = slice.children[5].text.to_i
				poss = fga_value + to_value + (fta_value / 2) - or_value
				if slice.children[0].children.size > 1
					position = slice.children[0].children[1].text
				end
				unless player = game.players.find_by(player_name: player_name, team_abbr: team_abbr)
		           	player = game.players.create(player_name: player_name, team_abbr: team_abbr)
	            end
	            player.update(position: position, state: index + 1, poss: poss)
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
					player_index = player_name.index(' ')
					player_name = player_index ? player_name[player_index+1..-1] : ""
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
			end
		end
	end

	task :getUpdatePoss => [:environment] do
		include Api
		Time.zone = 'Eastern Time (US & Canada)'
		games = Nba.where("game_date between ? and ?", (Date.today - 3.days).beginning_of_day, Time.now)
		puts games.size

		games.each do |game|
			now = game.game_date
			if now > Time.now
				now = Time.now
			end
			last_games = Nba.where("home_team = ? AND game_date < ?", game.home_team, now).or(Nba.where("away_team = ? AND game_date < ?", game.home_team, now)).order('game_date DESC').limit(5)
			(1..5).each do |index|
				player = game.players.where("state = ? AND team_abbr = ?", index, 1).first
				sum_poss = 0
				team_poss = 0
				last_games.each do |last_game|
					last_players = last_game.players.where("player_name = ?",player.player_name)
					if last_players.size > 0
						sum_poss = sum_poss + last_players.first.poss
						last_team = last_game.players.where("player_name = ?", "TEAM")
						team_poss = team_poss + last_team.first.poss
					end
				end
				player.update(sum_poss: sum_poss, team_poss: team_poss)
			end

			last_games = Nba.where("home_team = ? AND game_date < ?", game.away_team, now).or(Nba.where("away_team = ? AND game_date < ?", game.away_team, now)).order('game_date DESC').limit(5)
			(1..5).each do |index|
				player = game.players.where("state = ? AND team_abbr = ?", index, 0).first
				sum_poss = 0
				team_poss = 0
				last_games.each do |last_game|
					last_players = last_game.players.where("player_name = ?",player.player_name)
					if last_players.size > 0
						sum_poss = sum_poss + last_players.first.poss
						last_team = last_game.players.where("player_name = ?", "TEAM")
						team_poss = team_poss + last_team.first.poss
					end
				end
				player.update(sum_poss: sum_poss, team_poss: team_poss)
			end
		end
	end

	task :getUpdateTG => [:environment] do
		include Api
		games = Nba.where("game_date between ? and ?", (Date.today - 3.days).beginning_of_day, Date.today.end_of_day)
		puts games.size
		games.each do |game|
			players = game.players.all
			players.each do |player|
				year = 2017
		        team_abbr = game.home_abbr
		        if player.team_abbr == 0
					team_abbr = game.away_abbr
				end
		        if @team_nicknames[team_abbr]
					team_abbr = @team_nicknames[team_abbr]
					
					player_name = player.player_name
					player_name_index = player_name.index(". ")
					player_name = player_name_index ? player_name[player_name_index+2..-1] : ""
					
					if player_element = Tg.find_by(player_name: player_name, team_abbr: team_abbr, year: year)
						player.update(ortg: player_element.ortg, drtg: player_element.drtg)
					end
				end
			end
		end
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
end