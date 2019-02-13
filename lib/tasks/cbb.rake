namespace :cbb do

	task :daily => :environment do
    (-2..5).each do |element|
			date = Date.today + element.days
			Rake::Task["cbb:getDate"].invoke(date.strftime("%Y%m%d"))
			Rake::Task["cbb:getDate"].reenable
    end

		Rake::Task["cbb:getScore"].invoke
		Rake::Task["cbb:getScore"].reenable

		Rake::Task["cbb:getLines"].invoke
		Rake::Task["cbb:getLines"].reenable

		Rake::Task["cbb:team_stats"].invoke
		Rake::Task["cbb:team_stats"].reenable

		Rake::Task["cbb:player_names"].invoke
		Rake::Task["cbb:player_names"].reenable

		Rake::Task["cbb:getCBBPlayer"].invoke
		Rake::Task["cbb:getCBBPlayer"].reenable

		Rake::Task["cbb:getNbaPlayer"].invoke
		Rake::Task["cbb:getNbaPlayer"].reenable

		Rake::Task["cbb:nba_player_names"].invoke
		Rake::Task["cbb:nba_player_names"].reenable
  end

  task :getLines => :environment do
		link = "https://classic.sportsbookreview.com/betting-odds/ncaa-basketball/?date="
		Rake::Task["cbb:getSecondLines"].invoke("full", link)
		Rake::Task["cbb:getSecondLines"].reenable

		link = "https://classic.sportsbookreview.com/betting-odds/ncaa-basketball/totals/?date="
		Rake::Task["cbb:getSecondLines"].invoke("fullTotal", link)
		Rake::Task["cbb:getSecondLines"].reenable
  end

	task :getDate, [:game_date] => [:environment] do |t, args|
		puts "----------Get Games----------"
		include Api
		Time.zone = 'Eastern Time (US & Canada)'
		game_date = args[:game_date]
		url = "http://www.espn.com/mens-college-basketball/schedule/_/date/#{game_date}"
		doc = download_document(url)
		puts url
  	index = { away_team: 0, home_team: 1, result: 2 }
  	elements = doc.css("tr")
  	elements.each do |slice|
      next if slice.children.size < 5
  		away_team = slice.children[index[:away_team]].text
      next if away_team == "matchup"

      home_team = ''
      home_abbr = ''
      away_abbr = ''
      home_link = ''
      away_link = ''

  		href = slice.children[index[:result]].child['href']
  		game_id = href[-9..-1]
      game = CbbGame.find_or_create_by(game_id: game_id)
      if slice.children[index[:home_team]].children[0].children.size == 2
  			home_team = slice.children[index[:home_team]].children[0].children[1].children[0].text
  			home_abbr = slice.children[index[:home_team]].children[0].children[1].children[2].text
        home_link = slice.children[index[:home_team]].children[0].children[1]['href']
  		elsif slice.children[index[:home_team]].children[0].children.size == 3
  			home_team = slice.children[index[:home_team]].children[0].children[2].children[0].text
  			home_abbr = slice.children[index[:home_team]].children[0].children[2].children[2].text
        home_link = slice.children[index[:home_team]].children[0].children[2]['href']
  		elsif slice.children[index[:home_team]].children[0].children.size == 1
  			home_team = slice.children[index[:home_team]].children[0].children[0].children[0].text
  			home_abbr = slice.children[index[:home_team]].children[0].children[0].children[2].text
        home_link = slice.children[index[:home_team]].children[0].children[0]['href']
  		end

  		if slice.children[index[:away_team]].children.size == 2
				away_abbr = slice.children[index[:away_team]].children[1].children[2].text
  			away_team = slice.children[index[:away_team]].children[1].children[0].text
        away_link = slice.children[index[:away_team]].children[1]['href']
			elsif slice.children[index[:away_team]].children.size == 3
				away_abbr = slice.children[index[:away_team]].children[2].children[2].text
				away_team = slice.children[index[:away_team]].children[2].children[0].text
        away_link = slice.children[index[:away_team]].children[2]['href']
			elsif slice.children[index[:away_team]].children.size == 1
				away_abbr = slice.children[index[:away_team]].children[0].children[2].text
  			away_team = slice.children[index[:away_team]].children[0].children[0].text
        away_link = slice.children[index[:away_team]].children[0]['href']
      end
			game.update(away_team: away_team, home_team: home_team, home_abbr: home_abbr, away_abbr: away_abbr)

  		url = "http://www.espn.com/mens-college-basketball/game?gameId=#{game_id}"
  		doc = download_document(url)
			puts url
      if doc
				element = doc.css(".game-date-time").first
        if element
					game_date = element.children[1]['data-date']
					date = DateTime.parse(game_date).in_time_zone

					game.update(game_date: date)
        end
			end

      home_team = CbbTeam.find_or_create_by(name: home_team, abbr: home_abbr, link: home_link)
      away_team = CbbTeam.find_or_create_by(name: away_team, abbr: away_abbr, link: away_link)

  		url = "http://www.espn.com/mens-college-basketball/boxscore?gameId=#{game_id}"
  		doc = download_document(url)
      puts url

      if doc
				away_players = doc.css('#gamepackage-boxscore-module .gamepackage-away-wrap tbody tr')
				end_index = away_players.size - 3
				(0..end_index).each do |element|
					slice = away_players[element]

					if slice.children[0].children.size > 1
						link = slice.children[0].children[0]['href']
					else
						link = ""
					end

					min_value = 0
					pts_value = 0
					if slice.children.size > 13
						min_value = slice.children[1].text.to_i
						pts_value = slice.children[13].text.to_i
					end

					player = CbbPlayer.find_or_create_by(link: link, cbb_team_id: away_team.id)
					record = CbbRecord.find_or_create_by(cbb_player_id: player.id, cbb_game_id: game.id)
					record.update(min: min_value, score: pts_value, team: 0, order: element, cbb_team_id: away_team.id, game_date: date)
				end

				home_players = doc.css('#gamepackage-boxscore-module .gamepackage-home-wrap tbody tr')
				end_index = home_players.size - 3
				(0..end_index).each do |element|
					slice = home_players[element]
					if slice.children[0].children.size > 1
						link = slice.children[0].children[0]['href']
						puts link
					else
						link = ""
					end

					min_value = 0
					pts_value = 0
					if slice.children.size > 13
						min_value = slice.children[1].text.to_i
						pts_value = slice.children[13].text.to_i
					end
					player = CbbPlayer.find_or_create_by(link: link, cbb_team_id: home_team.id)
					record = CbbRecord.find_or_create_by(cbb_player_id: player.id, cbb_game_id: game.id)
					record.update(min: min_value, score: pts_value, team: 1, order: element, cbb_team_id: home_team.id, game_date: date)
        end
      end
		end
  end

	task :team_stats => :environment do
		include Api
		teams = CbbTeam.all
    teams.each do |team|
      link = team.link
      next unless link

      team_stats = 'http://www.espn.com' + link.gsub('_', 'stats/_')
      puts team_stats
      doc = download_document(team_stats)
      if doc
				elements = doc.css('tr td tbody tr td')
				records = doc.css('tr tr td tbody tr')
				elements.each_with_index do |element, index|
					break if element.text == 'Total'

					player_link = element.children[0].children[0]['href']
					player = CbbPlayer.find_or_create_by(cbb_team_id: team.id, link: player_link)
					player.update(ave_mins: records[index].children[1].text)
        end
      end

			team_roster = 'http://www.espn.com' + link.gsub('_', 'roster/_')
			doc = download_document(team_roster)
			elements = doc.css("tr tr tbody tr")
			elements.each do |slice|
				player_link = slice.children[1].children[0].children[0]['href']
				player = CbbPlayer.find_or_create_by(cbb_team_id: team.id, link: player_link)
				player.update(player_class: slice.children[5].children[0].text)
			end
    end
  end

  task :player_names => :environment do
		include Api
		players = CbbPlayer.where('player_name is null')
		players.each do |player|
      next unless player.link
			doc = download_document(player.link)
      unless doc
        puts player.link
        next
      end
			player_name = doc.css("h1")[0].text
      player.update(player_name: player_name)
    end
  end

  task :duplicatePlayer => :environment do
		players = CbbPlayer.all
    links = []
		players.each do |player|
			next unless player.link
			dup = CbbPlayer.where(link: player.link)
      if dup.count(:id) > 1
        links.push(player.link)
      end
    end
    puts links.inspect
  end

	task :getCBBPlayer => :environment do
		include Api
		url = "https://basketball.realgm.com/ncaa/teams"
		doc = download_document(url)
		team_links = doc.css("tbody tr td:first-child a")
		team_links.each do |team_link|
			team_name = team_link.text
      team_name = @team_name[team_name] if @team_name[team_name]
			matched_team = CbbTeam.find_by(name: team_name)
			matched_team_id = matched_team.id
			team_url = 'https://basketball.realgm.com' + team_link['href'] + 'players'
			team_doc = download_document(team_url)
			players = team_doc.css("tbody tr")
			players.each do |player|
				next if player.children[15]['rel'] != '2019'
        player_name = player.children[1].text.squish
				birthday = player.children[9].text
        next if birthday == '-'
        player_name = player_name.remove(',')
        player_name = @cbb_player_name[player_name] if @cbb_player_name[player_name]
			 	matched_player = CbbPlayer.find_by(player_name: player_name, cbb_team_id: matched_team_id)
				matched_player = CbbPlayer.find_by(player_name: player_name + ' Jr.', cbb_team_id: matched_team_id) unless matched_player
				matched_player = CbbPlayer.find_by(player_name: player_name + ' II', cbb_team_id: matched_team_id) unless matched_player
				matched_player = CbbPlayer.find_by(player_name: player_name + ' III', cbb_team_id: matched_team_id) unless matched_player
				unless matched_player
					player_name = player_name.remove(' Jr.')
					matched_player = CbbPlayer.find_by(player_name: player_name, cbb_team_id: matched_team_id)
        end
				unless matched_player
					player_name = player_name.remove('.')
					matched_player = CbbPlayer.find_by(player_name: player_name, cbb_team_id: matched_team_id)
				end
				unless matched_player
					player_name = player_name.remove(' II')
					matched_player = CbbPlayer.find_by(player_name: player_name, cbb_team_id: matched_team_id)
				end
				unless matched_player
					player_name = player_name.remove(' III')
					matched_player = CbbPlayer.find_by(player_name: player_name, cbb_team_id: matched_team_id)
				end
        if matched_player
					matched_player.update(birthdate: birthday)
        end
			end
    end
  end

  task :getNbaPlayer => :environment do
		include Api
		url = "http://www.espn.com/nba/teams"
		doc = download_document(url)
		teams = doc.css('.TeamLinks')
		teams.each do |team|
      team_element = team.children[1].children[0]
			team_link = team_element['href']
      team_name = team_element.children[0].text
      team_bracket = team_name.rindex(' ')
      team_name = team_name[0..team_bracket-1] if team_bracket
			team_name = @team_name[team_name] if @team_name[team_name]
			team_roster = 'http://www.espn.com' + team_link.gsub('_', 'roster/_')
			doc = download_document(team_roster)
			elements = doc.css("tr tr tbody tr")
			elements.each do |slice|
				player_link = slice.children[1].children[0].children[0]['href']
				player = NbaPlayer.find_or_create_by(team_name: team_name, link: player_link)

				doc = download_document(player_link)
        next unless doc
				player_name = doc.css('h1')[0].text
				birthdate = doc.css(".player-metadata")[0]
				if birthdate.children[0]
					birthdate = birthdate.children[0].children[1].text
					first_bracket = birthdate.rindex('(')
          birthdate = birthdate[0..first_bracket-1] if first_bracket
          second_bracket = birthdate.rindex(' in ')
					birthdate = birthdate[0..second_bracket-1] if second_bracket
				else
					birthdate = nil
        end
				player.update(player_name: player_name, birthdate: birthdate)
			end
    end
  end

	task :nba_player_names => :environment do
		include Api
		players = NbaPlayer.where('player_name is null')
		players.each do |player|
			doc = download_document(player.link)
			next unless doc
			player_name = doc.css('h1')[0].text
			birthday = doc.css(".player-metadata")[0]
			if birthday.children[0]
				birthday = birthday.children[0].children[1].text
				first_bracket = birthday.rindex('(')
				birthday = birthday[0..first_bracket-1] if first_bracket
				second_bracket = birthdate.rindex(' in ')
				birthday = birthday[0..second_bracket-1] if second_bracket
			else
				birthday = nil
			end
			player.update(player_name: player_name, birthdate: birthday)
		end
  end

	task :getScore => [:environment] do
		include Api
		games = CbbGame.where("game_date between ? and ?", Date.yesterday.beginning_of_day, Date.today.end_of_day)
		puts games.size
		games.each do |game|
			game_id = game.game_id

			url = "http://www.espn.com/mens-college-basketball/game?gameId=#{game_id}"
			doc = download_document(url)
			puts url
			elements = doc.css("#linescore tbody tr")
			if elements.size > 1
				if elements[0].children.size > 3
					away_first_quarter 	= elements[0].children[1].text.to_i
					away_second_quarter = elements[0].children[2].text.to_i
					away_ot_quarter 	= 0

					home_first_quarter 	= elements[1].children[1].text.to_i
					home_second_quarter = elements[1].children[2].text.to_i
					home_ot_quarter 	= 0

					if elements[0].children.size > 4
						away_ot_quarter = elements[0].children[3].text.to_i
						home_ot_quarter = elements[1].children[3].text.to_i
					end
				end
			else
				away_first_quarter 	= 0
				away_second_quarter = 0
				away_ot_quarter 	= 0

				home_first_quarter 	= 0
				home_second_quarter = 0
				home_ot_quarter 	= 0
			end
			away_score = away_first_quarter + away_second_quarter + away_ot_quarter
			home_score = home_first_quarter + home_second_quarter + home_ot_quarter

			game.update(
          away_first_quarter: away_first_quarter,
          home_first_quarter: home_first_quarter,
          away_second_quarter: away_second_quarter,
          home_second_quarter: home_second_quarter,
          away_ot_quarter: away_ot_quarter,
          home_ot_quarter: home_ot_quarter,
          away_score: away_score,
          home_score: home_score)
    end
  end

	task :getSecondLines, [:type, :game_link] => [:environment] do |t, args|
		include Api
		games = CbbGame.where("game_date between ? and ?", (Date.today - 3.days).beginning_of_day, (Date.today + 3.days).end_of_day)
		game_link = args[:game_link]
		type = args[:type]
		puts "----------Get #{type} Lines----------"

		index_date = Date.yesterday
		while index_date <= Date.tomorrow  do
			game_day = index_date.strftime("%Y%m%d")
			puts game_day
			url = "#{game_link}#{game_day}"
			doc = download_document(url)
			elements = doc.css(".event-holder")
			elements.each do |element|
				if element.children[0].children[1].children.size > 2 && element.children[0].children[1].children[2].children[1].children.size == 1
					next
				end
				if element.children[0].children[5].children.size < 5
					next
        end

				score_element = element.children[0].children[11]
				score_element = element.children[0].children[9] if score_element.children[1].text == ""
				score_element = element.children[0].children[13] if score_element.children[1].text == ""
				score_element = element.children[0].children[12] if score_element.children[1].text == ""
				score_element = element.children[0].children[10] if score_element.children[1].text == ""
				score_element = element.children[0].children[17] if score_element.children[1].text == ""
				score_element = element.children[0].children[18] if score_element.children[1].text == ""
				score_element = element.children[0].children[14] if score_element.children[1].text == ""
				score_element = element.children[0].children[15] if score_element.children[1].text == ""
				score_element = element.children[0].children[16] if score_element.children[1].text == ""

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

				home_name = @cbb_nicknames[home_name] if @cbb_nicknames[home_name]
				away_name = @cbb_nicknames[away_name] if @cbb_nicknames[away_name]

        home_name_index = home_name.index(') ')
        home_name = home_name[home_name_index+2..-1] if home_name_index
				away_name_index = away_name.index(') ')
				away_name = away_name[away_name_index+2..-1] if away_name_index
        puts home_name
        puts away_name

				date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 5.hours +  hour.hours

				line_one = opener.index(" ")
				opener_side = line_one ? opener[0..line_one] : ""
				line_two = closer.index(" ")
				closer_side = line_two ? closer[0..line_two] : ""

				matched = games.select{|field| ((field.home_team.include?(home_name) && field.away_team.include?(away_name)) || (field.home_team.include?(away_name) && field.away_team.include?(home_name))) && (date == field.game_date) }
				if matched.size > 0
					update_game = matched.first
					if opener_side.include?('½')
						if opener_side[0] == '-'
							opener_side = opener_side[0..-1].to_f - 0.5
						else
							opener_side = opener_side[0..-1].to_f + 0.5
						end
					else
						opener_side = opener_side.to_f
					end
					if closer_side.include?('½')
						if closer_side[0] == '-'
							closer_side = closer_side[0..-1].to_f - 0.5
						else
							closer_side = closer_side[0..-1].to_f + 0.5
						end
					else
						closer_side = closer_side.to_f
					end
					puts opener_side
					puts closer_side
					if type == "full"
						update_game.update(full_opener_side: opener_side, full_closer_side: closer_side)
					elsif type == "fullTotal"
							update_game.update(full_opener_total: opener_side, full_closer_total: closer_side)
					end
				end
			end
			index_date = index_date + 1.days
		end
	end


  # Clone
	task :dailyClone => :environment do
		date = Date.new(2019, 1, 2)
		while date <= Date.tomorrow  do
			Rake::Task["cbb:getDate"].invoke(date.strftime("%Y%m%d"))
			Rake::Task["cbb:getDate"].reenable
			date = date + 1.days
		end

		Rake::Task["cbb:getScoreClone"].invoke
		Rake::Task["cbb:getScoreClone"].reenable

		link = "https://classic.sportsbookreview.com/betting-odds/ncaa-basketball/?date="
		Rake::Task["cbb:getSecondLinesClone"].invoke("full", link)
		Rake::Task["cbb:getSecondLinesClone"].reenable

		link = "https://classic.sportsbookreview.com/betting-odds/ncaa-basketball/totals/?date="
		Rake::Task["cbb:getSecondLinesClone"].invoke("fullTotal", link)
		Rake::Task["cbb:getSecondLinesClone"].reenable
  end

	task :getScoreClone => [:environment] do
		include Api
		games = CbbGame.where("game_date between ? and ?", Date.new(2018, 11, 5).beginning_of_day, Date.today.end_of_day)
		puts games.size
		games.each do |game|
			game_id = game.game_id

			url = "http://www.espn.com/mens-college-basketball/game?gameId=#{game_id}"
			doc = download_document(url)
			puts url
			elements = doc.css("#linescore tbody tr")
			if elements.size > 1
				if elements[0].children.size > 3
					away_first_quarter 	= elements[0].children[1].text.to_i
					away_second_quarter = elements[0].children[2].text.to_i
					away_ot_quarter 	= 0

					home_first_quarter 	= elements[1].children[1].text.to_i
					home_second_quarter = elements[1].children[2].text.to_i
					home_ot_quarter 	= 0

					if elements[0].children.size > 4
						away_ot_quarter = elements[0].children[3].text.to_i
						home_ot_quarter = elements[1].children[3].text.to_i
					end
				end
			else
				away_first_quarter 	= 0
				away_second_quarter = 0
				away_ot_quarter 	= 0

				home_first_quarter 	= 0
				home_second_quarter = 0
				home_ot_quarter 	= 0
			end
			away_score = away_first_quarter + away_second_quarter + away_ot_quarter
			home_score = home_first_quarter + home_second_quarter + home_ot_quarter

			game.update(
					away_first_quarter: away_first_quarter,
					home_first_quarter: home_first_quarter,
					away_second_quarter: away_second_quarter,
					home_second_quarter: home_second_quarter,
					away_ot_quarter: away_ot_quarter,
					home_ot_quarter: home_ot_quarter,
					away_score: away_score,
					home_score: home_score)
		end
	end

	task :getSecondLinesClone, [:type, :game_link] => [:environment] do |t, args|
		include Api
		games = CbbGame.where("game_date between ? and ?", Date.new(2018, 11, 5).beginning_of_day, (Date.today + 3.days).end_of_day)
		game_link = args[:game_link]
		type = args[:type]
		puts "----------Get #{type} Lines----------"

		index_date = Date.new(2018, 11, 5)
		while index_date <= Date.tomorrow  do
			game_day = index_date.strftime("%Y%m%d")
			puts game_day
			url = "#{game_link}#{game_day}"
			doc = download_document(url)
			elements = doc.css(".event-holder")
			elements.each do |element|
				if element.children[0].children[1].children.size > 2 && element.children[0].children[1].children[2].children[1].children.size == 1
					next
				end
				if element.children[0].children[5].children.size < 5
					next
				end

				score_element = element.children[0].children[11]
				score_element = element.children[0].children[9] if score_element.children[1].text == ""
				score_element = element.children[0].children[13] if score_element.children[1].text == ""
				score_element = element.children[0].children[12] if score_element.children[1].text == ""
				score_element = element.children[0].children[10] if score_element.children[1].text == ""
				score_element = element.children[0].children[17] if score_element.children[1].text == ""
				score_element = element.children[0].children[18] if score_element.children[1].text == ""
				score_element = element.children[0].children[14] if score_element.children[1].text == ""
				score_element = element.children[0].children[15] if score_element.children[1].text == ""
				score_element = element.children[0].children[16] if score_element.children[1].text == ""

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

				home_name = @cbb_nicknames[home_name] if @cbb_nicknames[home_name]
				away_name = @cbb_nicknames[away_name] if @cbb_nicknames[away_name]

				home_name_index = home_name.index(') ')
				home_name = home_name[home_name_index+2..-1] if home_name_index
				away_name_index = away_name.index(') ')
				away_name = away_name[away_name_index+2..-1] if away_name_index
				puts home_name
				puts away_name

				date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 5.hours +  hour.hours

				line_one = opener.index(" ")
				opener_side = line_one ? opener[0..line_one] : ""
				line_two = closer.index(" ")
				closer_side = line_two ? closer[0..line_two] : ""

				matched = games.select{|field| ((field.home_team.include?(home_name) && field.away_team.include?(away_name)) || (field.home_team.include?(away_name) && field.away_team.include?(home_name))) && (date == field.game_date) }
				if matched.size > 0
					update_game = matched.first
					if opener_side.include?('½')
						if opener_side[0] == '-'
							opener_side = opener_side[0..-1].to_f - 0.5
						else
							opener_side = opener_side[0..-1].to_f + 0.5
						end
					else
						opener_side = opener_side.to_f
					end
					if closer_side.include?('½')
						if closer_side[0] == '-'
							closer_side = closer_side[0..-1].to_f - 0.5
						else
							closer_side = closer_side[0..-1].to_f + 0.5
						end
					else
						closer_side = closer_side.to_f
					end
					puts opener_side
					puts closer_side
					if type == "full"
						update_game.update(full_opener_side: opener_side, full_closer_side: closer_side)
					elsif type == "fullTotal"
						update_game.update(full_opener_total: opener_side, full_closer_total: closer_side)
					end
				end
			end
			index_date = index_date + 1.days
    end
  end


	@cbb_nicknames = {
			"St. Peter's" => "Saint Peter's",
      "Connecticut" => "UConn",
      "Loyola (IL)" => "Loyola-Chicago",
      "Southern University" => "Southern",
      "Grambling State" => "Grambling"
	}

	@team_name = {
			'American University' => 'American',
			'Brigham Young' => 'BYU',
			'Cal State Bakersfield' => 'CSU Bakersfield',
			'Cal State Fullerton' => 'CSU Fullerton',
			'Cal State Northridge' => 'CSU Northridge',
      'Central Connecticut State' => 'Central Connecticut',
			'Citadel' => 'The Citadel',
			'Connecticut' => 'UConn',
			'Detroit-Mercy' => 'Detroit Mercy',
			'Fort Wayne' => 'Purdue Fort Wayne',
			'Grambling State' => 'Grambling',
			'Hawaii' => "Hawai'i",
			'Illinois-Chicago' => 'UIC',
			'Long Island' => 'LIU Brooklyn',
			'Louisiana-Monroe' => 'UL Monroe',
			'Loyola (IL)' => 'Loyola-Chicago',
			'Massachusetts' => 'UMass',
			'McNeese State' => 'McNeese',
			'Miami (FL)' => 'Miami',
			'Middle Tennessee State' => 'Middle Tennessee',
			"Mount St. Mary's" => "Mt. St. Mary's",
			'N.J.I.T.' => 'NJIT',
			'Nicholls State' => 'Nicholls',
			'San Jose State' => 'San José St',
			'Southeast Missouri State' => 'SE Missouri St',
			'Southeastern Louisiana' => 'SE Louisiana',
			'Southern Methodist' => 'SMU',
      'Southern Mississippi' => 'Southern Miss',
      'St. Francis (NY)' => 'St. Francis (BKN)',
      'Tennessee-Martin' => 'UT Martin',
      'Texas Christian' => 'TCU',
      'Texas-Arlington' => 'UT Arlington',
      'Texas-RGV' => 'UT Rio Grande Valley',
      'Texas-San Antonio' => 'UTSA',
      'USC Upstate' => 'South Carolina Upstate',
      'Virginia Military' => 'VMI',
      'LA' => 'LAC',
      'Los Angeles' => 'LAL'
	}

  @cbb_player_name = {
      'Christopher Joyce' => 'Chris Joyce',
      "Charles O'Briant" => "Charlie O'Briant",
      'Ryan Swan-Ford' => 'Ryan Swan',
      'Loren Jackson' => 'Loren Cristian Jackson',
      'Lepear Toles' => 'LePear Toles',
      'Herb Jones' => 'Herbert Jones',
      'Leon Freeman-Daniels' => 'Leon Daniels',
      'Reggie Gee' => 'Reginald Gee',
      'Jabriel Allen' => 'Khari Jabriel Allen',
      'Deshaw Andrews' => 'DeShaw Andrews',
      'TyQuayion Smith' => 'TyQuaylon Smith',
			'Reginald Johnson Jr.' => 'Reginal Johnson',
      'Mike Bibby' => 'Michael Bibby',
      'Lugentz Dort' => 'Luguentz Dort',
      'Mike Besselink' => 'Michael Besselink',
      'Sebastian Townes' => 'SaBastian Townes',
      'Mantvydas Urmilevicius' => 'Monty Urmilevicius',
      'Justin Elder-Davis' => 'Justin Edler-Davis',
  		'Laquill Hardnett' => 'LaQuill Hardnett',
      'Elijah Parquet' => 'Eli Parquet',
      'McKinley Wright' => 'McKinley Wright IV',
      'Alter Gilbert' => 'Alterique Gilbert',
      'Mitchell Ballock' => 'Mitch Ballock',
      'Obi Toppin' => 'Obadiah Toppin',
      'Elijah Cain' => 'Eli Cain',
      'Cameron Reddish' => 'Cam Reddish',
      'DeAundre Ballard' => 'Deaundrae Ballard',
      'Kevaughn Allen' => 'KeVaughn Allen',
      'Raysean Scott Jr.' => 'RaySean Scott Jr.',
  		'Arnaldo Toro Barea' => 'Arnaldo Toro',
      'Joshua LeBlanc' => 'Josh LeBlanc',
      'Jagan Mosley' => 'Jagan Mosely',
      'Will Jackson' => 'William Jackson II',
			'Tank Hemphill' => 'Shanquan Hemphill',
      'Danilo Djurick' => 'Danilo Djuricic',
      'Brandon Kamga' => 'Brandonn Kamga',
      'Clifford Thomas Jr.' => 'Cliff Thomas Jr.',
			'Charlie Thomas' => 'Charles Thomas IV',
      'DeSean Murray' => 'Desean Murray',
      'Doc Nelson' => 'Ricky Nelson',
      'Mike Wynn' => 'Michael Wynn',
      "Mike'l Simms" => "Mike'L Simms",
      'Vincent Williams' => 'Vince Williams',
      'Max Evans' => 'Maxwell Evans',
			'Simi Shittu' => 'Simisola Shittu',
      'Baker Evelyn' => 'Bakari Evelyn',
      'Kasper Christensen' => 'Kasper Christiansen',
			'Jamal Hartwell' => 'Jamal Hartwell II',
      'James Banks' => 'James Banks III',
      'Elijah Pemberton' => 'Eli Pemberton',
      'DeJon Jarreau' => 'Dejon Jarreau',
      'Mike Barber' => 'Michael Barber',
      'Desmond Balentine' => 'Des Balentine',
			'Jakob Forrester' => 'Jake Forrester',
      'Luke Garza' => 'Luka Garza',
      'Nicholas Hobbs' => 'Nicolas Hobbs',
			'Mitchell Lightfoot' => 'Mitch Lightfoot',
      'Pierson Mcatee' => 'Pierson McAtee',
      'B.J. Dulling' => 'BJ Duling',
			'Dave Beatty' => 'David Beatty',
			'Jorge Pacheco-Ortiz' => 'Georgie Pacheco-Ortiz',
      'Zack Flener' => 'Zach Flener',
      'Temidayo Yussef' => 'Temidayo Yussuf',
      'Julius Van Sauers' => 'Julius van Sauers',
      'Daquan Bracey' => 'DaQuan Bracey',
      'A.J. Durham' => 'Aljami Durham',
      'Jacolby Pemberton' => 'JaColby Pemberton',
      'James Batemon III' => 'James Batemon',
      'Jeffrey McClendon' => 'Jeffery McClendon',
			"Ja'Vonte Smart" => "Ja'vonte Smart",
      'Tom Capuano' => 'Thomas Capuano',
      'Matt Glassman' => 'Matthew Glassman',
      'Anthony Lawrence Jr.' => 'Anthony Lawrence II',
      'Connor George' => 'Conner George',
      'Josh Langford' => 'Joshua Langford',
			"Chuck O'Bannon Jr." => "Charles O'Bannon Jr.",
      'Jonathan Tchatchoua' => 'Jonathan Tchamwa Tchatchoua',
			"Jay Greene" => 'Jay Green',
      'Francisco Alonso' => 'Francis Alonso',
      'Kenny Nwuba' => 'Kenneth Nwuba',
			"Ar'mond Davis" => "Ar'Mond Davis",
      "Tamell Peason" => "Tamell Pearson",
      "Bejamin Litteken" => 'Benjamin Litteken',
			'Will Sessoms' => 'Wil Sessoms',
      'Torrance Watson' => 'Torrence Watson',
      'Joshua Webster' => 'Josh Webster',
      'Kjell De Graff' => 'Kjell de Graaf',
      'Thorir Thorbjarnarsson' => 'Thorir Thorbjarnarson',
			"Karim Ezzedine" => 'Karim Ezzeddine',
      'Qua Copeland' => 'Quavius Copeland',
      'Reggie Garnder' => 'Reggie Gardner Jr.',
  		'Brian Coffey Jr.' => 'Brian Coffey II',
      'Cameron Copeland' => 'Cam Copeland',
      'Victor Law' => 'Vic Law',
      'Vontay Ott' => 'Vonte Ott',
      'A.J. Oliver' => 'Anthony Oliver II',
      'Alfredos Pilavios' => 'Alfis Pilavios',
      'Stevie Thompson' => 'Stephen Thompson Jr.',
      'Jahbril Pryce-Noel' => 'Jahbril Price-Noel',
			"Sidy N'dir" => "Sidy N'Dir",
      'B.J. Martin' => 'Robert Martin',
			"Izayah Mauriohooho Le'Afa" => "Izayah Mauriohooho-Le'afa",
			"Jarel Spellman" => "Jare'l Spellman",
      'Ingvi Thor Gudmundsson' => 'Ingvi Gudmundsson',
      'Craig Lecesne' => 'Craig LeCesne',
      'Mattia Campo' => 'Mattia Da Campo',
			"Trey'von Hopkins" => 'Trey Hopkins',
      'Matthew Johns' => 'Matt Johns',
			"David Ndiaye" => "Daouda N'Diaye",
			"Marvin Clark Jr." => 'Marvin Clark II',
      'Kezie Okpala' => 'KZ Okpala',
      'OShae Brissett' => 'Oshae Brissett',
      'Donte Fitzpatrick' => 'Donte Fitzpatrick-Dorsey',
      'DelFincko Bogan' => 'Delfincko Bogan',
      'Trent Williams' => 'Trenten Williams',
			"Kerwin Roach Jr." => 'Kerwin Roach II',
      'Joshua Mballa' => 'Josh Mballa',
      "Mike Layssard Jr." => 'Mike Layssard'
    }
end