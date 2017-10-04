namespace :setup do
	task :all => :environment do
		year = 2010
			end_week = 15
			game_link = "college-football"
			(0..1).each do |index|
				(1..end_week).each do |week_index|
					Rake::Task["setup:link"].invoke(year, game_link, week_index)
					Rake::Task["setup:link"].reenable
				end
				end_week = 17
				game_link = "nfl"
			end
	end

	task :rest => :environment do
		Rake::Task["setup:previous"].invoke(2017, "college-football", 3)
	end

	task :min => :environment do
		day = Time.now
		day_index = day.strftime("%j").to_i
		result = (day_index + 2) / 7 - 35
		week_index = (result < 0) ? (0) : result

		game_link = "nfl"
		(0..1).each do |index|
			Rake::Task["setup:link"].invoke(2017, game_link, week_index+index)
			Rake::Task["setup:link"].reenable
			game_link = "college-football"
		end
		game_day = (Time.now - 4.hours).to_formatted_s(:number)[0..7]
		Rake::Task["setup:second"].invoke(game_day)
		Rake::Task["setup:second"].reenable
		game_day = (Time.now - 28.hours).to_formatted_s(:number)[0..7]
		Rake::Task["setup:second"].invoke(game_day)
		Rake::Task["setup:second"].reenable
	end

	task :link, [:year, :game_link, :week_index] => [:environment] do |t, args|
		include Api

		game_link = args[:game_link]
		week_index = args[:week_index]
		year = args[:year]
		game_type = "NFL"
		if game_link == "college-football"
			game_type = "CFB"
		end

		url = "http://www.espn.com/#{game_link}/schedule/_/week/#{week_index}/year/#{year}"
		doc = download_document(url)
		puts url
	  	index = { away_team: 0, home_team: 1, result: 2 }
	  	elements = doc.css("tr")
	  	elements.each do |slice|
	  		if slice.children.size < 6
	  			next
	  		end
	  		away_team = slice.children[index[:away_team]].text
	  		if away_team == "matchup"
	  			next
	  		end
	  		href = slice.children[index[:result]].child['href']
	  		game_id = href[-9..-1]
	  		unless game = Game.find_by(game_id: game_id)
              	game = Game.create(game_id: game_id)
            end

            url = "http://www.espn.com/#{game_link}/matchup?gameId=#{game_id}"
  			doc = download_document(url)
			puts url
  			element = doc.css(".game-time").first
  			game_status = element.text

            if slice.children[index[:home_team]].text == "TBD TBD"
            	result 		= "TBD"
            	home_team 	= "TBD"
            	home_abbr 	= "TBD"
            	away_abbr 	= "TBD"
            	away_team 	= "TBD"
            else
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
	  		end
	  		game_state = 4
	  		if result.include?("Canceled") || result.include?("TBD") || result.include?("Postponed")
	  			game_state = 6
	  		elsif game_status.include?("Final")
	  			game_state = 5
	  		elsif game_status.include?("4th") || game_status.include?("3rd")
	  			game_state = 3
	  		elsif game_status.include?("Half")
	  			game_state = 0
	  		elsif game_status.include?("2nd")
	  			game_state = 1
	  		elsif game_status.include?("1st")
	  			game_state = 2
	  		end

  			if game_state < 3 || game_state == 5
  				scores = doc.css(".score")
  				away_result = scores[0].text
  				home_result = scores[1].text

	            td_elements = doc.css("#gamepackage-matchup td")
	            home_team_total 	= ""
	            away_team_total 	= ""
	            home_team_rushing 	= ""
	            away_team_rushing 	= ""
	            td_elements.each_slice(3) do |slice|
	            	if slice[0].text.include?("Total Yards")
	            		away_team_total = slice[1].text
	            		home_team_total = slice[2].text
	            	end
	            	if slice[0].text.include?("Rushing") && !slice[0].text.include?("Rushing Attempts") && !slice[0].text.include?("Rushing 1st")
	            		away_team_rushing = slice[1].text
	            		home_team_rushing = slice[2].text
	            		break
	            	end
	            end

	            url = "http://www.espn.com/#{game_link}/boxscore?gameId=#{game_id}"
		  		doc = download_document(url)
				puts url
		  		element = doc.css("#gamepackage-rushing .gamepackage-home-wrap .highlight td")
		  		home_car 		= ""
		  		home_ave_car 	= ""
		  		home_rush_long 	= ""
		  		if element.size > 5
			  		home_car 		= element[1].text
			  		home_ave_car 	= element[3].text
			  		home_rush_long 	= element[5].text
			  	end

		  		element = doc.css("#gamepackage-rushing .gamepackage-away-wrap .highlight td")
		  		away_car 		= ""
		  		away_ave_car 	= ""
		  		away_rush_long 	= ""
		  		if element.size > 5
			  		away_car 		= element[1].text
			  		away_ave_car 	= element[3].text
			  		away_rush_long 	= element[5].text
			  	end

		  		element = doc.css("#gamepackage-receiving .gamepackage-home-wrap .highlight td")
		  		home_pass_long 	= ""
		  		if element.size > 5
		  			home_pass_long 	= element[5].text
		  		end

		  		element = doc.css("#gamepackage-receiving .gamepackage-away-wrap .highlight td")
		  		away_pass_long 	= ""
		  		if element.size > 5
		  			away_pass_long 	= element[5].text
		  		end

				element = doc.css("#gamepackage-passing .gamepackage-home-wrap .highlight td")
				home_c_att 		= ""
				home_ave_att 	= ""
				home_total_play = ""
				home_play_yard 	= ""

		  		if element.size > 5
					home_c_att 		= element[1].text
					home_ave_att 	= element[3].text

					home_att_index 	= home_c_att.index("/")
					home_total_play = home_car.to_i + home_c_att[home_att_index+1..-1].to_i
					home_play_yard 	= home_team_total.to_f / home_total_play
				end

				element = doc.css("#gamepackage-passing .gamepackage-away-wrap .highlight td")
				away_c_att 		= ""
				away_ave_att 	= ""
				away_total_play = ""
				away_play_yard 	= ""
		  		if element.size > 5
					away_c_att 		= element[1].text
					away_ave_att 	= element[3].text

					away_att_index 	= away_c_att.index("/")
					away_total_play = away_car.to_i + away_c_att[away_att_index+1..-1].to_i
					away_play_yard 	= away_team_total.to_f / away_total_play
				end

				element = doc.css("#gamepackage-defensive .gamepackage-home-wrap .highlight td")
				home_sacks = ""
				if element.size > 3
					home_sacks 		= element[3].text
				end

				element = doc.css("#gamepackage-defensive .gamepackage-away-wrap .highlight td")
				away_sacks = ""
				if element.size > 3
					away_sacks 		= element[3].text
				end


	            if game_state == 5
	  				unless score = game.scores.find_by(result: "Final")
		              	score = game.scores.create(result: "Final")
		            end
		            score.update(game_status: game_status, home_team_total: home_team_total, away_team_total: away_team_total, home_team_rushing: home_team_rushing, away_team_rushing: away_team_rushing, home_result: home_result, away_result: away_result, home_car: home_car, home_ave_car: home_ave_car, home_rush_long: home_rush_long, home_c_att: home_c_att, home_ave_att: home_ave_att, home_total_play: home_total_play, home_play_yard: home_play_yard, home_sacks: home_sacks, away_car: away_car, away_ave_car: away_ave_car, away_rush_long: away_rush_long, away_c_att: away_c_att, away_ave_att: away_ave_att, away_total_play: away_total_play, away_play_yard: away_play_yard, away_sacks: away_sacks, home_pass_long: home_pass_long, away_pass_long: away_pass_long)
	            elsif game_state < 3
		            unless score = game.scores.find_by(result: "Half")
		              	score = game.scores.create(result: "Half")
		            end
		            if game_state == 2
		            	game_status = "1Q"
		            elsif game_state == 1
		            	game_time_index = game_status.index(" ")
		            	game_status = game_status[0..game_time_index]
		            	if game_status.index(":") == 1
		            		game_status = "0" + game_status
		            	end
		            end
		            score.update(game_status: game_status, home_team_total: home_team_total, away_team_total: away_team_total, home_team_rushing: home_team_rushing, away_team_rushing: away_team_rushing, home_result: home_result, away_result: away_result, home_car: home_car, home_ave_car: home_ave_car, home_rush_long: home_rush_long, home_c_att: home_c_att, home_ave_att: home_ave_att, home_total_play: home_total_play, home_play_yard: home_play_yard, home_sacks: home_sacks, away_car: away_car, away_ave_car: away_ave_car, away_rush_long: away_rush_long, away_c_att: away_c_att, away_ave_att: away_ave_att, away_total_play: away_total_play, away_play_yard: away_play_yard, away_sacks: away_sacks, home_pass_long: home_pass_long, away_pass_long: away_pass_long)
		       	end
  			end

  			url = "http://www.espn.com/#{game_link}/game?gameId=#{game_id}"
	  		doc = download_document(url)
			puts url
	  		element = doc.css(".game-date-time").first
	  		game_date = element.children[1]['data-date']

	  		kicked = ""
	  		first_drive = game.first_drive
	  		second_drive = game.second_drive
	  		if result != "" && result != "TBD" && result != "Canceled" && result != "Postponed"
				url = "http://www.espn.com/#{game_link}/playbyplay?gameId=#{game_id}"
				puts url
		  		doc = download_document(url)
		  		away_img = doc.css(".away img")
		  		if away_img.size > 0
		  			away_img = away_img[1]['src'][-20..-1]
		  		else
		  			away_image = "NoImage"
		  		end
		  		check_img = doc.css(".accordion-header img")
		  		if game_state < 3
		  			first_drive = check_img.size
		  		elsif game_state == 5
		  			second_drive = check_img.size
		  			if game.first_drive.to_i == 0
				  		check_img_detail = doc.css(".css-accordion .accordion-item")
				  		check_img_detail.each_with_index do |element, index|
				  			if element.children.size == 3
				  				first_drive = index
				  				break
				  			end
				  		end
		  			end
		  		end
		  		if check_img.size > 0 && away_image != "NoImage"
		  			if game_state < 4
		  				check_img = check_img[check_img.size-1]['src'][-20..-1]
		  			else
		  				check_img = check_img[0]['src'][-20..-1]
		  			end
			  		kicked = "away"
			  		if check_img == away_img
			  			kicked = "home"
			  		end
			  	end
		  	end
		  	if game.game_state == 1 && game_state == 0
		  		game_status = Time.now
		  	elsif game.game_state == 0 && game_state == 0
		  		game_status = game.game_status
		  	end
  			game.update(away_team: away_team, home_team: home_team, game_type: game_type, game_date: game_date, home_abbr: home_abbr, away_abbr: away_abbr, kicked: kicked, game_state: game_state, game_status: game_status, first_drive: first_drive, second_drive: second_drive)
	  	end
	end

	task :hourly => :environment do
		include Api

		games = Game.all
	  	game_index = []
		games.each do |game|
			if game.game_date.to_s != "" && game.game_date < Time.now + 7.days && game.game_date > Time.now - 2.days
				game_index << game.game_date.to_formatted_s(:number)[0..7]
			end
		end
		game_index = game_index.uniq
		game_index = game_index.sort

		game_link = "college-football"
		(0..1).each do |index|
			game_index.each do |game_day|
				puts game_day
				url = "https://www.sportsbookreview.com/betting-odds/#{game_link}/merged/?date=#{game_day}"
				doc = download_document(url)
				elements = doc.css(".event-holder")
				elements.each do |element|
					home_number 	= element.children[0].children[3].children[2].text
					away_number 	= element.children[0].children[3].children[1].text
					home_name 		= element.children[0].children[5].children[1].text
					away_name 		= element.children[0].children[5].children[0].text
					home_pinnacle 	= element.children[0].children[9].children[1].text
					away_pinnacle 	= element.children[0].children[9].children[0].text
					ind = home_name.index(") ")
					home_name = ind ? home_name[ind+2..-1] : home_name
					ind = away_name.index(") ")
					away_name = ind ? away_name[ind+2..-1] : away_name
					ind = home_name.index(" (")
					home_name = ind ? home_name[0..ind-1] : home_name
					ind = away_name.index(" (")
					away_name = ind ? away_name[0..ind-1] : away_name
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
					if @nicknames[home_name]
				      home_name = @nicknames[home_name]
				    end
				    if @nicknames[away_name]
				      away_name = @nicknames[away_name]
				    end
					date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 4.hours +  hour.hours
					matched = games.select{|field| field.home_team.include?(home_name) && field.away_team.include?(away_name) && field.game_date == date }
					if matched.size > 0
						update_game = matched.first
						update_game.update(home_number: home_number, away_number: away_number, home_pinnacle: home_pinnacle, away_pinnacle: away_pinnacle)
					end
					matched = games.select{|field| field.home_team.include?(away_name) && field.away_team.include?(home_name) && field.game_date == date }
					if matched.size > 0
						update_game = matched.first
						update_game.update(home_number: away_number, away_number: home_number, home_pinnacle: away_pinnacle, away_pinnacle:home_pinnacle )
					end
				end
			end
			game_link = "nfl-football"
		end
	end

	task :second, [:game_day] => [:environment] do |t, args|
		include Api

		game_day = args[:game_day]
		games = Game.all

		game_link = "college-football"
		(0..1).each do |index|
			url = "https://www.sportsbookreview.com/betting-odds/#{game_link}/merged/2nd-half/?date=#{game_day}"
			doc = download_document(url)
			puts url
			elements = doc.css(".event-holder")
			elements.each do |element|
				home_number 		= element.children[0].children[3].children[2].text.to_i
				away_number 		= element.children[0].children[3].children[1].text.to_i
				home_2nd_pinnacle 	= element.children[0].children[9].children[1].text
				away_2nd_pinnacle 	= element.children[0].children[9].children[0].text
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
				date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 4.hours + hour.hours
				matched = games.select{|field| (field.home_number == home_number && field.away_number == away_number && field.game_date == date) }
				if matched.size > 0
					update_game = matched.first
					update_game.update(home_2nd_pinnacle: home_2nd_pinnacle, away_2nd_pinnacle: away_2nd_pinnacle)
				end
				matched = games.select{|field| (field.home_number == away_number && field.away_number == home_number && field.game_date == date) }
				if matched.size > 0
					update_game = matched.first
					update_game.update(home_2nd_pinnacle: away_2nd_pinnacle , away_2nd_pinnacle: home_2nd_pinnacle)
				end
			end
			game_link = "nfl-football"
		end
	end

	task gethourly: :environment do
		include Api

		games = Game.all
	  	game_index = []
		games.each do |game|
			if game.game_date.to_s != "" && game.game_date < Time.new(2011,1,1) && game.game_date > Time.new(2010,1,1)
				game_index << game.game_date.to_formatted_s(:number)[0..7]
			end
		end
		game_index = game_index.uniq
		game_index = game_index.sort

		game_link = "college-football"
		(0..1).each do |index|
			game_index.each do |game_day|
				puts game_day
				url = "https://www.sportsbookreview.com/betting-odds/#{game_link}/merged/?date=#{game_day}"
				doc = download_document(url)
				elements = doc.css(".event-holder")
				elements.each do |element|
					home_number 	= element.children[0].children[3].children[2].text
					away_number 	= element.children[0].children[3].children[1].text
					home_name 		= element.children[0].children[5].children[1].text
					away_name 		= element.children[0].children[5].children[0].text
					home_pinnacle 	= element.children[0].children[9].children[1].text
					away_pinnacle 	= element.children[0].children[9].children[0].text
					ind = home_name.index(") ")
					home_name = ind ? home_name[ind+2..-1] : home_name
					ind = away_name.index(") ")
					away_name = ind ? away_name[ind+2..-1] : away_name
					ind = home_name.index(" (")
					home_name = ind ? home_name[0..ind-1] : home_name
					ind = away_name.index(" (")
					away_name = ind ? away_name[0..ind-1] : away_name
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
					if @nicknames[home_name]
				      home_name = @nicknames[home_name]
				    end
				    if @nicknames[away_name]
				      away_name = @nicknames[away_name]
				    end
					date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 4.hours + hour.hours
					matched = games.select{|field| field.home_team.include?(home_name) && field.away_team.include?(away_name) && field.game_date == date }
					if matched.size > 0
						update_game = matched.first
						update_game.update(home_number: home_number, away_number: away_number, home_pinnacle: home_pinnacle, away_pinnacle: away_pinnacle)
					end
					matched = games.select{|field| field.home_team.include?(away_name) && field.away_team.include?(home_name) && field.game_date == date }
					if matched.size > 0
						update_game = matched.first
						update_game.update(home_number: away_number, away_number: home_number, home_pinnacle: away_pinnacle, away_pinnacle:home_pinnacle )
					end
				end
			end
			game_link = "nfl-football"
		end
	end

	task getsecond: :environment do
		include Api

		games = Game.all
	  	game_index = []
		games.each do |game|
			if game.game_date.to_s != "" && game.game_date < Time.new(2011,1,1) && game.game_date > Time.new(2010,1,1)
				game_index << game.game_date.to_formatted_s(:number)[0..7]
			end
		end
		game_index = game_index.uniq
		game_index = game_index.sort

		game_link = "college-football"
		(0..1).each do |index|
			game_index.each do |game_day|

				url = "https://www.sportsbookreview.com/betting-odds/#{game_link}/merged/2nd-half/?date=#{game_day}"
				doc = download_document(url)
				puts url
				elements = doc.css(".event-holder")
				elements.each_with_index do |element, index|
					home_number 		= element.children[0].children[3].children[2].text.to_i
					away_number 		= element.children[0].children[3].children[1].text.to_i
					home_2nd_pinnacle 	= element.children[0].children[9].children[1].text
					away_2nd_pinnacle 	= element.children[0].children[9].children[0].text
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
					date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 4.hours + hour.hours
					matched = games.select{|field| (field.home_number == home_number && field.away_number == away_number && field.game_date == date) }
					if matched.size > 0
						update_game = matched.first
						update_game.update(home_2nd_pinnacle: home_2nd_pinnacle, away_2nd_pinnacle: away_2nd_pinnacle)
					end
					matched = games.select{|field| (field.home_number == away_number && field.away_number == home_number && field.game_date == date) }
					if matched.size > 0
						update_game = matched.first
						update_game.update(home_2nd_pinnacle: away_2nd_pinnacle , away_2nd_pinnacle: home_2nd_pinnacle)
					end
				end
			end
			game_link = "nfl-football"
		end
	end

	task test: :environment do
		include Api
		game_link="college-football"
		game_id = "400945256"
		away_abbr = "UNM"
		home_abbr = "BSU"
		
		home_team_passing = 0
		away_team_passing = 0
		home_team_rushing = 0
		away_team_rushing = 0
		home_car = 0
		away_car = 0
		home_attr = 2
		away_attr = 2
		home_rush_long = 0
		away_rush_long = 0
		home_pass_long = 0
  		away_pass_long = 0
  		home_c = 0
  		away_c = 0
  		home_result = 0
  		away_result = 0


        url = "http://www.espn.com/#{game_link}/playbyplay?gameId=#{game_id}"
		puts url
  		doc = download_document(url)

  		away_img = doc.css(".away img")
  		if away_img.size > 0
  			away_img = away_img[1]['src'][-20..-1]
  		else
  			away_img = "NoImage"
  		end

  		home_img = doc.css(".home img")
  		if home_img.size > 0
  			home_img = home_img[1]['src'][-20..-1]
  		else
  			home_img = "NoImage"
  		end

  		kicked = 2

  		elements = doc.css(".css-accordion .accordion-item")
  		second_drive = elements.size
  		elements.each_with_index do |element, index|
  			if element.children.length == 3
  				next
  			end
  			puts element.children[0].children[0].children[0].children[0].inspect
  			image =  element.children[0].children[0].children[0].children[0]
  			if image.children.size == 0
  				image = "NoImage"
  			else
  				image = image.children[0]['src'][-20..-1]
  			end
  			puts image
  			team_abbr = 0
  			if image == home_img
  				team_abbr = 1
  			elsif image == away_img
  				team_abbr = 0
  			else
  				puts "Image Missing"
  			end

  			if kicked == 2
  				kicked = team_abbr
  			end

  			lists = element.children[1].children[0].children[0]
  			list_length = (lists.children.length-1)/2
  			(1..list_length).each do |list_index|
  				list = lists.children[list_index*2-1]
  				header = list.children[1].text
  				string = list.children[3].children[1].children[0].text
  				string = string[20..-1]
  				if string.include?(" pass complete ") && !string.include?("NO PLAY")
  					value = string[/\d+/].to_i
  					if string.include?(" loss ")
  						value = -value
  					end
  					if team_abbr == 1
  						home_attr = home_attr + 1
  						home_c = home_c + 1
  						home_team_passing = home_team_passing + value
  						if value > home_pass_long
  							home_pass_long = value
  						end
  					else
  						away_attr = away_attr + 1
  						away_c = away_c + 1
  						away_team_passing = away_team_passing + value
  						if value > away_pass_long
  							away_pass_long = value
  						end
  					end
  					puts team_abbr
  					puts value
  					puts "pass"
  				end
  				if string.include?(" pass incomplete ") && !string.include?("NO PLAY")
  					if team_abbr == 1
  						home_attr = home_attr + 1
  					else
  						away_attr = away_attr + 1
  					end
  					puts team_abbr
  					puts "pass incomplete"
  				end
  				if string.include?(" run ") && !string.include?("NO PLAY")
  					value = string[/\d+/].to_i
  					if string.include?(" loss ")
  						value = -value
  					end
  					if string.include?(" no gain ")
  						value = 0
  					end
  					if team_abbr == 1
  						home_car = home_car + 1
  						home_team_rushing = home_team_rushing + value
  						if value > home_rush_long
  							home_rush_long = value
  						end
  					else
  						away_car = away_car + 1
  						away_team_rushing = away_team_rushing + value
  						if value > away_rush_long
  							away_rush_long = value
  						end
  					end
  					puts team_abbr
  					puts value
  					puts "russ"
  				end
  				if string.include?(" sacked ") && string.include?(" loss ") && !string.include?("NO PLAY")
  					value = string[/\d+/].to_i
  					value = -value
  					if team_abbr == 1
  						home_team_rushing = home_team_rushing + value
  					else
  						away_team_rushing = away_team_rushing + value
  					end
  					puts team_abbr
  					puts value
  					puts "sacked"
  				end
  			end
  			if element.children[0].text.include?("End of Half")
  				first_drive = index + 1
  				score = element.children[0].children[0].children[1]
  				away_result = score.children[0].children[1].text
  				home_result = score.children[1].children[1].text
  			end
  		end

  		if kicked == 1
  			kicked = "home"
  		elsif kicked == 0
  			kicked = "away"
  		else
  			kicked = ""
  		end

  		home_team_total = home_team_rushing + home_team_passing
  		away_team_total = away_team_rushing + away_team_passing

        home_ave_car = (home_team_rushing.to_f / home_car).round(2)
        away_ave_car = (away_team_rushing.to_f / away_car).round(2)

        home_c_att = home_c.to_s + "/" + home_attr.to_s
        away_c_att = away_c.to_s + "/" + away_attr.to_s

        home_ave_att = (home_team_passing.to_f / home_attr).round(2)
        away_ave_att = (away_team_passing.to_f / away_attr).round(2)

        home_total_play = home_car + home_attr
		home_play_yard 	= home_team_total.to_f / home_total_play

		away_total_play = away_car + away_attr
		away_play_yard 	= away_team_total.to_f / away_total_play

  		puts home_total_passing
  		puts home_total_rushing
  		puts away_total_passing
  		puts away_total_rushing
  		puts home_car
  		puts away_car
  		puts first_drive
  		puts second_drive
	end

	task :previous, [:year, :game_link, :week_index] => [:environment] do |t, args|
		include Api

		game_link = args[:game_link]
		week_index = args[:week_index]
		year = args[:year]
		game_type = "NFL"
		if game_link == "college-football"
			game_type = "CFB"
		end

		url = "http://www.espn.com/#{game_link}/schedule/_/week/#{week_index}/year/#{year}"
		doc = download_document(url)
		puts url
	  	index = { away_team: 0, home_team: 1, result: 2 }
	  	elements = doc.css("tr")
	  	elements.each do |slice|
	  		if slice.children.size < 6
	  			next
	  		end
	  		away_team = slice.children[index[:away_team]].text
	  		if away_team == "matchup"
	  			next
	  		end
	  		href = slice.children[index[:result]].child['href']
	  		game_id = href[-9..-1]
	  		unless game = Game.find_by(game_id: game_id)
              	game = Game.create(game_id: game_id)
            end

            url = "http://www.espn.com/#{game_link}/matchup?gameId=#{game_id}"
  			doc = download_document(url)
			puts url
  			element = doc.css(".game-time").first
  			game_status = element.text

            if slice.children[index[:home_team]].text == "TBD TBD"
            	result 		= "TBD"
            	home_team 	= "TBD"
            	home_abbr 	= "TBD"
            	away_abbr 	= "TBD"
            	away_team 	= "TBD"
            else
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
	  		end
	  		game_state = 4
	  		if game_status.include?("Final")
	  			game_state = 5
  				scores = doc.css(".score")
  				away_result = scores[0].text
  				home_result = scores[1].text

	            td_elements = doc.css("#gamepackage-matchup td")
	            home_team_total 	= ""
	            away_team_total 	= ""
	            home_team_rushing 	= ""
	            away_team_rushing 	= ""
	            td_elements.each_slice(3) do |slice|
	            	if slice[0].text.include?("Total Yards")
	            		away_team_total = slice[1].text
	            		home_team_total = slice[2].text
	            	end
	            	if slice[0].text.include?("Rushing") && !slice[0].text.include?("Rushing Attempts") && !slice[0].text.include?("Rushing 1st")
	            		away_team_rushing = slice[1].text
	            		home_team_rushing = slice[2].text
	            		break
	            	end
	            end
	            if false 
	  				unless score = game.scores.find_by(result: "Final")
		              	score = game.scores.create(result: "Final")
		            end
		            score.update(game_status: game_status, home_team_total: home_team_total, away_team_total: away_team_total, home_team_rushing: home_team_rushing, away_team_rushing: away_team_rushing, home_result: home_result, away_result: away_result)
		        end

	            home_team_passing = 0
				away_team_passing = 0
				home_team_rushing = 0
				away_team_rushing = 0
				home_car = 0
				away_car = 0
				home_attr = 2
				away_attr = 2
				home_rush_long = 0
				away_rush_long = 0
				home_pass_long = 0
		  		away_pass_long = 0
		  		home_c = 0
		  		away_c = 0
		  		home_result = 0
		  		away_result = 0


		        url = "http://www.espn.com/#{game_link}/playbyplay?gameId=#{game_id}"
				puts url
		  		doc = download_document(url)

		  		away_img = doc.css(".away img")
		  		if away_img.size > 0
		  			away_img = away_img[1]['src'][-20..-1]
		  		else
		  			away_img = "NoImage"
		  		end

		  		home_img = doc.css(".home img")
		  		if home_img.size > 0
		  			home_img = home_img[1]['src'][-20..-1]
		  		else
		  			home_img = "NoImage"
		  		end

		  		kicked = 2

		  		elements = doc.css(".css-accordion .accordion-item")
		  		second_drive = elements.size
		  		elements.each_with_index do |element, index|
		  			if element.children.length == 3
		  				next
		  			end
		  			puts element.children[0].children[0].children[0].children[0].inspect
		  			image =  element.children[0].children[0].children[0].children[0]
		  			if image.children.size == 0
		  				image = "NoImage"
		  			else
		  				image = image.children[0]['src'][-20..-1]
		  			end
		  			puts image
		  			team_abbr = 0
		  			if image == home_img
		  				team_abbr = 1
		  			elsif image == away_img
		  				team_abbr = 0
		  			else
		  				puts "Image Missing"
		  			end

		  			if kicked == 2
		  				kicked = team_abbr
		  			end

		  			lists = element.children[1].children[0].children[0]
		  			list_length = (lists.children.length-1)/2
		  			(1..list_length).each do |list_index|
		  				list = lists.children[list_index*2-1]
		  				header = list.children[1].text
		  				string = list.children[3].children[1].children[0].text
		  				string = string[20..-1]
		  				if string.include?(" pass complete ") && !string.include?("NO PLAY")
		  					value = string[/\d+/].to_i
		  					if string.include?(" loss ")
		  						value = -value
		  					end
		  					if team_abbr == 1
		  						home_attr = home_attr + 1
		  						home_c = home_c + 1
		  						home_team_passing = home_team_passing + value
		  						if value > home_pass_long
		  							home_pass_long = value
		  						end
		  					else
		  						away_attr = away_attr + 1
		  						away_c = away_c + 1
		  						away_team_passing = away_team_passing + value
		  						if value > away_pass_long
		  							away_pass_long = value
		  						end
		  					end
		  				end
		  				if string.include?(" pass incomplete ") && !string.include?("NO PLAY")
		  					if team_abbr == 1
		  						home_attr = home_attr + 1
		  					else
		  						away_attr = away_attr + 1
		  					end
		  				end
		  				if string.include?(" run ") && !string.include?("NO PLAY")
		  					value = string[/\d+/].to_i
		  					if string.include?(" loss ")
		  						value = -value
		  					end
		  					if string.include?(" no gain ")
		  						value = 0
		  					end
		  					if team_abbr == 1
		  						home_car = home_car + 1
		  						home_team_rushing = home_team_rushing + value
		  						if value > home_rush_long
		  							home_rush_long = value
		  						end
		  					else
		  						away_car = away_car + 1
		  						away_team_rushing = away_team_rushing + value
		  						if value > away_rush_long
		  							away_rush_long = value
		  						end
		  					end
		  				end
		  				if string.include?(" sacked ") && string.include?(" loss ") && !string.include?("NO PLAY")
		  					value = string[/\d+/].to_i
		  					value = -value
		  					if team_abbr == 1
		  						home_team_rushing = home_team_rushing + value
		  					else
		  						away_team_rushing = away_team_rushing + value
		  					end
		  				end
		  			end
		  			if element.children[0].text.include?("End of Half")
		  				first_drive = index + 1
		  				score = element.children[0].children[0].children[1]
		  				away_result = score.children[0].children[1].text
		  				home_result = score.children[1].children[1].text
		  			end
		  		end

		  		if kicked == 1
		  			kicked = "home"
		  		elsif kicked == 0
		  			kicked = "away"
		  		else
		  			kicked = ""
		  		end

		  		home_team_total = home_team_rushing + home_team_passing
		  		away_team_total = away_team_rushing + away_team_passing

	            home_ave_car = (home_team_rushing.to_f / home_car).round(2)
	            away_ave_car = (away_team_rushing.to_f / away_car).round(2)

	            home_c_att = home_c.to_s + "/" + home_attr.to_s
	            away_c_att = away_c.to_s + "/" + away_attr.to_s

	            home_ave_att = (home_team_passing.to_f / home_attr).round(2)
	            away_ave_att = (away_team_passing.to_f / away_attr).round(2)

	            home_total_play = home_car + home_attr
				home_play_yard 	= home_team_total.to_f / home_total_play

				away_total_play = away_car + away_attr
				away_play_yard 	= away_team_total.to_f / away_total_play

			  	unless score = game.scores.find_by(result: "previous")
	              	score = game.scores.create(result: "previous")
	            end
	            score.update(game_status: game_status, home_team_total: home_team_total, away_team_total: away_team_total, home_team_rushing: home_team_rushing, away_team_rushing: away_team_rushing, home_result: home_result, away_result: away_result, home_car: home_car, home_ave_car: home_ave_car, home_rush_long: home_rush_long, home_c_att: home_c_att, home_ave_att: home_ave_att, home_total_play: home_total_play, home_play_yard: home_play_yard, away_car: away_car, away_ave_car: away_ave_car, away_rush_long: away_rush_long, away_c_att: away_c_att, away_ave_att: away_ave_att, away_total_play: away_total_play, away_play_yard: away_play_yard, home_pass_long: home_pass_long, away_pass_long: away_pass_long)
		        
			end

			url = "http://www.espn.com/#{game_link}/game?gameId=#{game_id}"
	  		doc = download_document(url)
			puts url
	  		element = doc.css(".game-date-time").first
	  		game_date = element.children[1]['data-date']
	  		if false
  				game.update(away_team: away_team, home_team: home_team, game_type: game_type, game_date: game_date, home_abbr: home_abbr, away_abbr: away_abbr, kicked: kicked, game_state: game_state, game_status: game_status, first_drive: first_drive, second_drive: second_drive)
  			end
	  	end
	end

	@nicknames = {
    	"Hawaii" => "Hawai'i",
    	"San Jose State" => "San José State",
    	"Brigham Young" => "BYU",
    	"Massachusetts" => "UMass",
    	"Florida International" => "Florida Intl",
		"Louisiana-Monroe" => "Louisiana Monroe",
		"Central Connecticut State" => "Central Connecticu",
		"Virginia Military Institute" => "VMI",
		"North Carolina State" => "NC State",
		"Louisiana-Lafayette" => "Louisiana",
		"Grambling State" => "Grambling",
		"Tennessee-Martin" => "UT Martin",
		"Southern Methodist" => "SMU",
		"Nicholls State" => "Nicholls",
		"Southern University" => "Southern",
		"Southern Miss" => "Southern Mississippi",
		"UTSA" => "UT San Antonio",
		"N.Y. Jets" => "New York",
		"L.A. Rams" => "Los Angeles",
		"N.Y. Giants" => "New York",
		"L.A. Chargers" => "Los Angeles",
		"Los Angeles" => "St. Louis",
		"SC State" => "South Carolina State",
		"Stephen F. Austin" => "Stephen F Austin",
		"NC Central" => "North Carolina Central",
	}
end