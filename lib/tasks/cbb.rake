namespace :cbb do

	task :daily => :environment do
		date = Date.yesterday - 5.days
		Rake::Task["cbb:getDate"].invoke(date.strftime("%Y%m%d"))
		Rake::Task["cbb:getDate"].reenable

		date = Date.yesterday - 4.days
		Rake::Task["cbb:getDate"].invoke(date.strftime("%Y%m%d"))
		Rake::Task["cbb:getDate"].reenable

		date = Date.yesterday - 3.days
		Rake::Task["cbb:getDate"].invoke(date.strftime("%Y%m%d"))
		Rake::Task["cbb:getDate"].reenable

		date = Date.yesterday - 2.days
		Rake::Task["cbb:getDate"].invoke(date.strftime("%Y%m%d"))
		Rake::Task["cbb:getDate"].reenable

		date = Date.yesterday - 1.days
		Rake::Task["cbb:getDate"].invoke(date.strftime("%Y%m%d"))
		Rake::Task["cbb:getDate"].reenable

		date = Date.yesterday
		Rake::Task["cbb:getDate"].invoke(date.strftime("%Y%m%d"))
		Rake::Task["cbb:getDate"].reenable

    date = Date.today
    Rake::Task["cbb:getDate"].invoke(date.strftime("%Y%m%d"))
    Rake::Task["cbb:getDate"].reenable
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

  		url = "http://www.espn.com/mens-college-basketball/game?gameId=#{game_id}"
  		doc = download_document(url)
      puts url
  		element = doc.css(".game-date-time").first
  		game_date = element.children[1]['data-date']
  		date = DateTime.parse(game_date).in_time_zone

      game.update(away_team: away_team, home_team: home_team, home_abbr: home_abbr, away_abbr: away_abbr, game_date: date)

      home_team = CbbTeam.find_or_create_by(name: home_team, abbr: home_abbr, link: home_link)
      away_team = CbbTeam.find_or_create_by(name: away_team, abbr: away_abbr, link: away_link)

  		url = "http://www.espn.com/mens-college-basketball/boxscore?gameId=#{game_id}"
  		doc = download_document(url)
      puts url

			away_players = doc.css('#gamepackage-boxscore-module .gamepackage-away-wrap tbody tr')
			end_index = away_players.size - 3
			(0..end_index).each do |element|
				slice = away_players[element]

				if slice.children[0].children.size > 1
					player_name = slice.children[0].children[0].children[0].text
          link = slice.children[0].children[0]['href']
				else
					player_name = slice.children[0].text
          link = ""
        end

        min_value = 0
        pts_value = 0
        if slice.children.size > 13
          min_value = slice.children[1].text.to_i
          pts_value = slice.children[13].text.to_i
        end

        player = CbbPlayer.find_or_create_by(player_name: player_name, link: link, cbb_team_id: away_team.id)
				record = CbbRecord.find_or_create_by(cbb_player_id: player.id, cbb_game_id: game.id)
        record.update(min: min_value, score: pts_value, team: 0, order: element)
			end

			home_players = doc.css('#gamepackage-boxscore-module .gamepackage-home-wrap tbody tr')
			end_index = home_players.size - 3
			(0..end_index).each do |element|
				slice = home_players[element]
				if slice.children[0].children.size > 1
					player_name = slice.children[0].children[0].children[0].text
					link = slice.children[0].children[0]['href']
					puts link
				else
					player_name = slice.children[0].text
					link = ""
        end

        min_value = 0
        pts_value = 0
        if slice.children.size > 13
          min_value = slice.children[1].text.to_i
          pts_value = slice.children[13].text.to_i
        end
				player = CbbPlayer.find_or_create_by(player_name: player_name, link: link, cbb_team_id: home_team.id)
				record = CbbRecord.find_or_create_by(cbb_player_id: player.id, cbb_game_id: game.id)
				record.update(min: min_value, score: pts_value, team: 1, order: element)
			end
		end
  end

	task :team_stats => :environment do

	end
end