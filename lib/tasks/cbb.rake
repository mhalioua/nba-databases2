namespace :cbb do

	task :daily => :environment do
		date = Date.today - 5.days
		Rake::Task["cbb:getDate"].invoke(date.strftime("%Y%m%d"))
		Rake::Task["cbb:getDate"].reenable


		date = Date.today - 6.days
		Rake::Task["cbb:getDate"].invoke(date.strftime("%Y%m%d"))
		Rake::Task["cbb:getDate"].reenable


		date = Date.today - 7.days
		Rake::Task["cbb:getDate"].invoke(date.strftime("%Y%m%d"))
		Rake::Task["cbb:getDate"].reenable


		date = Date.today - 8.days
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
		include Api
		teams = CbbTeam.all
    teams.each do |team|
      link = team.link
      next unless link

      team_stats = 'http://www.espn.com' + link.gsub('_', 'stats/_')
			doc = download_document(team_stats)
			elements = doc.css("tr")
			elements.each do |slice|
				next if slice.children.size < 12
        next if slice.children[0].text == 'Player'
        break if slice.children[0].text == 'Totals'

        player_link = slice.children[0].children[0]['href']
        player_link_break = player_link.rindex('/')
        player_link = player_link[0..player_link_break-1] if player_link_break
        player = CbbPlayer.find_or_create_by(cbb_team_id: team.id, link: player_link)
        player.update(ave_mins: slice.children[2].text)
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
		players = CbbPlayer.all
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

	task :getCBBPlayer => :environment do
		include Api
		url = "https://basketball.realgm.com/ncaa/teams"
		doc = download_document(url)
		team_links = doc.css("tbody tr td:first-child a")
    missing_players = []
		team_links.each do |team_link|
			team_name = team_link.text
      team_name = @team_name[team_name] if @team_name[team_name]
			matched_team = CbbTeam.find_by(name: team_name)
			team_url = 'https://basketball.realgm.com' + team_link['href'] + 'players'
			team_doc = download_document(team_url)
			players = team_doc.css("tbody tr")
			players.each do |player|
				next if player.children[15]['rel'] != '2019'
        player_name = player.children[1].text
				birthday = player.children[9].text
			 	matched_player = CbbPlayer.find_by(player_name: player_name, cbb_team_id: matched_team.id)
        unless matched_player
          missing_player = {
              'team_name' => team_name,
              'player_name' => player_name
          }
          missing_players.push(missing_player)
        end
       #  puts team_name
       #  puts player_name
       #  puts birthday
       #  puts matched_player.inspect
			 # Cbb.find_or_create_by(player: player.children[1].text, birthdate: player.children[9].text, team_name: team_name)
			end
    end
    puts missing_players.inspect
  end

  task :duplicate => :environment do
    include Api
    players = CbbPlayer.where("ave_mins is null AND player_class is null")
    players.each do |player|
      matched = CbbPlayer.where("player_name = ? AND link >= ?", player.player_name, player.link)
      if matched.count(:id) > 1
        player.delete
      end
    end
  end

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
      'Virginia Military' => 'VMI'
	}

  @player_name = {
      'Christopher Joyce' => 'Chris Joyce',
      "Charles O'Briant" => "Charlie O'Briant",
      'Ryan Swan-Ford' => 'Ryan Swan',
      'Loren Jackson' => 'Loren Cristian Jackson',
      'Lepear Toles' => 'LePear Toles'
  }
end