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
      puts team_stats
      doc = download_document(team_stats)
      elements = doc.css('tr td tbody tr td')
      records = doc.css('tr tr td tbody tr')
      elements.each_with_index do |element, index|
				break if element.text == 'Total'

        player_link = element.children[0].children[0]['href']
        player = CbbPlayer.find_or_create_by(cbb_team_id: team.id, link: player_link)
        player.update(ave_mins: records[index].children[1].text)
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

  task :duplicatePlayer => :environment do
		players = CbbPlayer.all
		players.each do |player|
			next unless player.link
			dup = CbbPlayer.where(link: player.link)
      if dup.count(:id) > 1
        puts player.link
      end
		end
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