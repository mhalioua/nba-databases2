namespace :nba do
	task :getInjury => :environment do
    include Api
    today = Date.today
		url = "http://www.espn.com/nba/injuries"
    doc = download_document(url)
    elements = doc.css(".tablesm option")
    elements.each_with_index do |slice, index|
      if index == 0
        next
      end
      team = slice.text
      if @nba_nicknames[team]
        team = @nba_nicknames[team]
      end
      link = 'http:' + slice['value']
      page = download_document(link)
      lists = page.css('tr')
      date = ""
      lists.each_with_index do |list, index|
        if index == 0
          next
        end
        if list.children.size == 1
          date = list.children[0].text
        elsif list.children.size == 2
          name = list.children[0].children[0].children[1].text[1..-1]
          status = list.children[1].children[0].text
          text = list.children[1].children[2].text
          element = Injury.find_or_create_by(team: team, link: link, date: date, name: name, status: status, text: text, today: today)
        end
      end
    end

    injuries = Injury.where(today: today)
    injuries.each do |injury|
      injury_date = Date.strptime(injury.date, "%b %e")
      injury_players = Player.where("player_fullname = ? AND game_date >= ?", injury.name, injury_date)
      if injury_players.size > 0
        Injury.delete(injury.id)
      end
    end

    Rake::Task["nba:getReferee"].invoke
    Rake::Task["nba:getReferee"].reenable

    Rake::Task["nba:getTodayReferee"].invoke
    Rake::Task["nba:getTodayReferee"].reenable

    Rake::Task["nba:getStarter"].invoke
    Rake::Task["nba:getStarter"].reenable
	end
  
	task :daily => :environment do
    Rake::Task["nba:teaminfo"].invoke
    Rake::Task["nba:teaminfo"].reenable
    
		date = Date.yesterday
		Rake::Task["nba:getDate"].invoke(date.strftime("%Y%m%d"))
		Rake::Task["nba:getDate"].reenable

    date = Date.today + 5.days
    Rake::Task["nba:getDate"].invoke(date.strftime("%Y%m%d"))
    Rake::Task["nba:getDate"].reenable

		Rake::Task["nba:getScore"].invoke
		Rake::Task["nba:getScore"].reenable

    Rake::Task["nba:fixingscores"].invoke
    Rake::Task["nba:fixingscores"].reenable

		Rake::Task["nba:getLinkGame"].invoke
		Rake::Task["nba:getLinkGame"].reenable

		Rake::Task["nba:gettg"].invoke
		Rake::Task["nba:gettg"].reenable

		Rake::Task["nba:getPlayer"].invoke
		Rake::Task["nba:getPlayer"].reenable

    Rake::Task["nba:getpg"].invoke
    Rake::Task["nba:getpg"].reenable

    Rake::Task["nba:addAVGs"].invoke
    Rake::Task["nba:addAVGs"].reenable

		Rake::Task["nba:getUpdateTG"].invoke
		Rake::Task["nba:getUpdateTG"].reenable

		Rake::Task["nba:getUpdatePoss"].invoke
		Rake::Task["nba:getUpdatePoss"].reenable

    Rake::Task["nba:filterNba"].invoke
    Rake::Task["nba:filterNba"].reenable
  end

  task :hourly => :environment do
    Rake::Task["nba:getFirstLines"].invoke
    Rake::Task["nba:getFirstLines"].reenable

    link = "https://classic.sportsbookreview.com/betting-odds/nba-basketball/2nd-half/?date="
    Rake::Task["nba:getSecondLines"].invoke("second", link)
    Rake::Task["nba:getSecondLines"].reenable

    link = "https://classic.sportsbookreview.com/betting-odds/nba-basketball/?date="
    Rake::Task["nba:getSecondLines"].invoke("full", link)
    Rake::Task["nba:getSecondLines"].reenable

    link = "https://classic.sportsbookreview.com/betting-odds/nba-basketball/totals/1st-half/?date="
    Rake::Task["nba:getSecondLines"].invoke("firstTotal", link)
    Rake::Task["nba:getSecondLines"].reenable

    link = "https://classic.sportsbookreview.com/betting-odds/nba-basketball/totals/2nd-half/?date="
    Rake::Task["nba:getSecondLines"].invoke("secondTotal", link)
    Rake::Task["nba:getSecondLines"].reenable

    link = "https://classic.sportsbookreview.com/betting-odds/nba-basketball/totals/?date="
    Rake::Task["nba:getSecondLines"].invoke("fullTotal", link)
    Rake::Task["nba:getSecondLines"].reenable
  end

	task :fix => :environment do
		include Api
    index = {
      team: 3,
      current: 5,
      last_three: 7,
      last_one: 9,
      home: 11,
      away: 13,
      last: 15
    }

    url = "https://www.teamrankings.com/nba/stat/offensive-rebounds-per-game"
    doc = download_document(url)
    elements = doc.css(".datatable tbody tr")
    elements.each do |slice|
      team       = slice.children[index[:team]].text
      current    = slice.children[index[:current]].text.to_f
      last_three = slice.children[index[:last_three]].text.to_f
      last_one   = slice.children[index[:last_one]].text.to_f
      home       = slice.children[index[:home]].text.to_f
      away       = slice.children[index[:away]].text.to_f
      last       = slice.children[index[:last]].text.to_f

      unless element = Team.find_by(team: team)
        element = Team.create(team: team)
      end
     	element.update(rebound_current: current, rebound_last_three: last_three, rebound_last_one: last_one, rebound_home: home, rebound_away: away, rebound_last: last)
    end

    url = "https://www.teamrankings.com/nba/stat/possessions-per-game"
    doc = download_document(url)
    elements = doc.css(".datatable tbody tr")
    elements.each do |slice|
      team       = slice.children[index[:team]].text
      current    = slice.children[index[:current]].text.to_f
      last_three = slice.children[index[:last_three]].text.to_f
      last_one   = slice.children[index[:last_one]].text.to_f
      home       = slice.children[index[:home]].text.to_f
      away       = slice.children[index[:away]].text.to_f
      last       = slice.children[index[:last]].text.to_f
      unless element = Team.find_by(team: team)
        element = Team.create(team: team)
      end
      element.update(possessions_current: current, possessions_last_three: last_three, possessions_last_one: last_one, possessions_home: home, possessions_away: away, possessions_last: last)
    end

    url = "https://www.teamrankings.com/nba/stat/steals-per-game"
    doc = download_document(url)
    elements = doc.css(".datatable tbody tr")
    elements.each do |slice|
      team       = slice.children[index[:team]].text
      current    = slice.children[index[:current]].text.to_f
      last_three = slice.children[index[:last_three]].text.to_f
      last_one   = slice.children[index[:last_one]].text.to_f
      home       = slice.children[index[:home]].text.to_f
      away       = slice.children[index[:away]].text.to_f
      last       = slice.children[index[:last]].text.to_f

      unless element = Team.find_by(team: team)
        element = Team.create(team: team)
      end
   		element.update(steal_current: current, steal_last_three: last_three, steal_last_one: last_one, steal_home: home, steal_away: away, steal_last: last)
    end

    url = "https://www.teamrankings.com/nba/stat/blocks-per-game"
    doc = download_document(url)
    elements = doc.css(".datatable tbody tr")

    elements.each do |slice|
      team       = slice.children[index[:team]].text
      current    = slice.children[index[:current]].text.to_f
      last_three = slice.children[index[:last_three]].text.to_f
      last_one   = slice.children[index[:last_one]].text.to_f
      home       = slice.children[index[:home]].text.to_f
      away       = slice.children[index[:away]].text.to_f
      last       = slice.children[index[:last]].text.to_f

      unless element = Team.find_by(team: team)
        element = Team.create(team: team)
      end
      element.update(block_current: current, block_last_three: last_three, block_last_one: last_one, block_home: home, block_away: away, block_last: last)
    end

    url = "https://www.teamrankings.com/nba/stat/turnovers-per-game"
    doc = download_document(url)
    elements = doc.css(".datatable tbody tr")

    elements.each do |slice|
      team       = slice.children[index[:team]].text
      current    = slice.children[index[:current]].text.to_f
      last_three = slice.children[index[:last_three]].text.to_f
      last_one   = slice.children[index[:last_one]].text.to_f
      home       = slice.children[index[:home]].text.to_f
      away       = slice.children[index[:away]].text.to_f
      last       = slice.children[index[:last]].text.to_f

      unless element = Team.find_by(team: team)
        element = Team.create(team: team)
      end
      element.update(turnover_current: current, turnover_last_three: last_three, turnover_last_one: last_one, turnover_home: home, turnover_away: away, turnover_last: last)
    end

    url = "http://www.espn.com/nba/standings/_/group/league"
    doc = download_document(url)
    teams = doc.css("abbr")
    elements = doc.css(".Table2__table .Table2__shadow-scroller .Table2__table-scroller tbody tr")
    puts elements.size
    elements.each_with_index do |slice, index|
      team_abbr  =  teams[index].text
      w          =  slice.children[0].text
      l          =  slice.children[1].text
      ppg        =  slice.children[8].text.to_f
      opp        =  slice.children[9].text.to_f
      diff       =  slice.children[10].text.to_f
      if element = Team.find_by(abbr: team_abbr)
        element.update(record_won: w, record_lost: l, record_ppg: ppg, record_opp: opp, record_diff: diff)
      end
    end

    url = "https://www.teamrankings.com/nba/stat/opponent-1st-half-points-per-game"
    doc = download_document(url)
    elements = doc.css(".datatable tbody tr")

    elements.each do |slice|
      team       = slice.children[index[:team]].text
      current    = slice.children[index[:current]].text.to_f
      last_three = slice.children[index[:last_three]].text.to_f
      last_one   = slice.children[index[:last_one]].text.to_f
      home       = slice.children[index[:home]].text.to_f
      away       = slice.children[index[:away]].text.to_f
      last       = slice.children[index[:last]].text.to_f

      unless element = Team.find_by(team: team)
        element = Team.create(team: team)
      end
      element.update(opponentfirst_current: current, opponentfirst_last_three: last_three, opponentfirst_last_one: last_one, opponentfirst_home: home, opponentfirst_away: away, opponentfirst_last: last)
    end

    url = "https://www.teamrankings.com/nba/stat/opponent-2nd-half-points-per-game"
    doc = download_document(url)
    elements = doc.css(".datatable tbody tr")

    elements.each do |slice|
      team       = slice.children[index[:team]].text
      current    = slice.children[index[:current]].text.to_f
      last_three = slice.children[index[:last_three]].text.to_f
      last_one   = slice.children[index[:last_one]].text.to_f
      home       = slice.children[index[:home]].text.to_f
      away       = slice.children[index[:away]].text.to_f
      last       = slice.children[index[:last]].text.to_f

      unless element = Team.find_by(team: team)
        element = Team.create(team: team)
      end
      element.update(opponentsecond_current: current, opponentsecond_last_three: last_three, opponentsecond_last_one: last_one, opponentsecond_home: home, opponentsecond_away: away, opponentsecond_last: last)
    end

    url = "https://www.teamrankings.com/nba/stat/1st-half-points-per-game"
    doc = download_document(url)
    elements = doc.css(".datatable tbody tr")

    elements.each do |slice|
      team       = slice.children[index[:team]].text
      current    = slice.children[index[:current]].text.to_f
      last_three = slice.children[index[:last_three]].text.to_f
      last_one   = slice.children[index[:last_one]].text.to_f
      home       = slice.children[index[:home]].text.to_f
      away       = slice.children[index[:away]].text.to_f
      last       = slice.children[index[:last]].text.to_f

      unless element = Team.find_by(team: team)
        element = Team.create(team: team)
      end
      element.update(first_current: current, first_last_three: last_three, first_last_one: last_one, first_home: home, first_away: away, first_last: last)
    end

    url = "https://www.teamrankings.com/nba/stat/2nd-half-points-per-game"
    doc = download_document(url)
    elements = doc.css(".datatable tbody tr")

    elements.each do |slice|
      team       = slice.children[index[:team]].text
      current    = slice.children[index[:current]].text.to_f
      last_three = slice.children[index[:last_three]].text.to_f
      last_one   = slice.children[index[:last_one]].text.to_f
      home       = slice.children[index[:home]].text.to_f
      away       = slice.children[index[:away]].text.to_f
      last       = slice.children[index[:last]].text.to_f

      unless element = Team.find_by(team: team)
        element = Team.create(team: team)
      end
      element.update(second_current: current, second_last_three: last_three, second_last_one: last_one, second_home: home, second_away: away, second_last: last)
    end

    games = Nba.where("game_date between ? and ?", (Date.today - 2.days).beginning_of_day, Time.now-5.hours)
    games.each do |game|
      home_team = game.team_stats.find_or_create_by(abbr: game.home_abbr)
      match_team = Team.find_by(abbr: game.home_abbr)
      if match_team
        home_team.update(
          team: match_team.team,
          possessions_current: match_team.possessions_current,
          possessions_last_three: match_team.possessions_last_three,
          possessions_last_one: match_team.possessions_last_one,
          possessions_home: match_team.possessions_home,
          possessions_away: match_team.possessions_away,
          possessions_last: match_team.possessions_last,
          rebound_current: match_team.rebound_current,
          rebound_last_three: match_team.rebound_last_three,
          rebound_last_one: match_team.rebound_last_one,
          rebound_home: match_team.rebound_home,
          rebound_away: match_team.rebound_away,
          rebound_last: match_team.rebound_last,
          steal_current: match_team.steal_current,
          steal_last_three: match_team.steal_last_three,
          steal_last_one: match_team.steal_last_one,
          steal_home: match_team.steal_home,
          steal_away: match_team.steal_away,
          steal_last: match_team.steal_last,
          block_current: match_team.block_current,
          block_last_three: match_team.block_last_three,
          block_last_one: match_team.block_last_one,
          block_home: match_team.block_home,
          block_away: match_team.block_away,
          block_last: match_team.block_last,
          turnover_current: match_team.turnover_current,
          turnover_last_three: match_team.turnover_last_three,
          turnover_last_one: match_team.turnover_last_one,
          turnover_home: match_team.turnover_home,
          turnover_away: match_team.turnover_away,
          turnover_last: match_team.turnover_last,
          record_won: match_team.record_won,
          record_lost: match_team.record_lost,
          record_ppg: match_team.record_ppg,
          record_opp: match_team.record_opp,
          record_diff: match_team.record_diff,
          opponentfirst_current: match_team.opponentfirst_current,
          opponentfirst_last_three: match_team.opponentfirst_last_three,
          opponentfirst_last_one: match_team.opponentfirst_last_one,
          opponentfirst_home: match_team.opponentfirst_home,
          opponentfirst_away: match_team.opponentfirst_away,
          opponentfirst_last: match_team.opponentfirst_last,
          opponentsecond_current: match_team.opponentsecond_current,
          opponentsecond_last_three: match_team.opponentsecond_last_three,
          opponentsecond_last_one: match_team.opponentsecond_last_one,
          opponentsecond_home: match_team.opponentsecond_home,
          opponentsecond_away: match_team.opponentsecond_away,
          opponentsecond_last: match_team.opponentsecond_last,
          first_current: match_team.first_current,
          first_last_three: match_team.first_last_three,
          first_last_one: match_team.first_last_one,
          first_home: match_team.first_home,
          first_away: match_team.first_away,
          first_last: match_team.first_last,
          second_current: match_team.second_current,
          second_last_three: match_team.second_last_three,
          second_last_one: match_team.second_last_one,
          second_home: match_team.second_home,
          second_away: match_team.second_away,
          second_last: match_team.second_last
        )
      end

      away_team = game.team_stats.find_or_create_by(abbr: game.away_abbr)
      match_team = Team.find_by(abbr: game.away_abbr)
      if match_team
        away_team.update(
          team: match_team.team,
          possessions_current: match_team.possessions_current,
          possessions_last_three: match_team.possessions_last_three,
          possessions_last_one: match_team.possessions_last_one,
          possessions_home: match_team.possessions_home,
          possessions_away: match_team.possessions_away,
          possessions_last: match_team.possessions_last,
          rebound_current: match_team.rebound_current,
          rebound_last_three: match_team.rebound_last_three,
          rebound_last_one: match_team.rebound_last_one,
          rebound_home: match_team.rebound_home,
          rebound_away: match_team.rebound_away,
          rebound_last: match_team.rebound_last,
          steal_current: match_team.steal_current,
          steal_last_three: match_team.steal_last_three,
          steal_last_one: match_team.steal_last_one,
          steal_home: match_team.steal_home,
          steal_away: match_team.steal_away,
          steal_last: match_team.steal_last,
          block_current: match_team.block_current,
          block_last_three: match_team.block_last_three,
          block_last_one: match_team.block_last_one,
          block_home: match_team.block_home,
          block_away: match_team.block_away,
          block_last: match_team.block_last,
          turnover_current: match_team.turnover_current,
          turnover_last_three: match_team.turnover_last_three,
          turnover_last_one: match_team.turnover_last_one,
          turnover_home: match_team.turnover_home,
          turnover_away: match_team.turnover_away,
          turnover_last: match_team.turnover_last,
          record_won: match_team.record_won,
          record_lost: match_team.record_lost,
          record_ppg: match_team.record_ppg,
          record_opp: match_team.record_opp,
          record_diff: match_team.record_diff,
          opponentfirst_current: match_team.opponentfirst_current,
          opponentfirst_last_three: match_team.opponentfirst_last_three,
          opponentfirst_last_one: match_team.opponentfirst_last_one,
          opponentfirst_home: match_team.opponentfirst_home,
          opponentfirst_away: match_team.opponentfirst_away,
          opponentfirst_last: match_team.opponentfirst_last,
          opponentsecond_current: match_team.opponentsecond_current,
          opponentsecond_last_three: match_team.opponentsecond_last_three,
          opponentsecond_last_one: match_team.opponentsecond_last_one,
          opponentsecond_home: match_team.opponentsecond_home,
          opponentsecond_away: match_team.opponentsecond_away,
          opponentsecond_last: match_team.opponentsecond_last,
          first_current: match_team.first_current,
          first_last_three: match_team.first_last_three,
          first_last_one: match_team.first_last_one,
          first_home: match_team.first_home,
          first_away: match_team.first_away,
          first_last: match_team.first_last,
          second_current: match_team.second_current,
          second_last_three: match_team.second_last_three,
          second_last_one: match_team.second_last_one,
          second_home: match_team.second_home,
          second_away: match_team.second_away,
          second_last: match_team.second_last
        )
      end
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
        away_pf_value = away_value.children[12].text.to_i
				away_fta_value = away_value.children[4].text
				away_fta_index = away_fta_value.index('-')
				away_fta_value = away_fta_index ? away_fta_value[away_fta_index+1..-1].to_i : 0
				away_or_value = away_value.children[5].text.to_i
        away_stl_value = away_value.children[9].text.to_i
        away_blk_value = away_value.children[10].text.to_i

				home_mins_value = home_value.children[1].text.to_i
				home_fga_value = home_value.children[2].text
				home_fga_index = home_fga_value.index('-')
				home_fga_value = home_fga_index ? home_fga_value[home_fga_index+1..-1].to_i : 0
				home_to_value = home_value.children[11].text.to_i
        home_pf_value = home_value.children[12].text.to_i
				home_fta_value = home_value.children[4].text
				home_fta_index = home_fta_value.index('-')
				home_fta_value = home_fta_index ? home_fta_value[home_fta_index+1..-1].to_i : 0
				home_or_value = home_value.children[5].text.to_i
        home_stl_value = home_value.children[9].text.to_i
        home_blk_value = home_value.children[10].text.to_i
			 end

      addingDate = date
      home_timezone = ''
      home_win_rank = 0
      home_ppg_rank = 0
      home_oppppg_rank = 0

      away_timezone = ''
      away_win_rank = 0
      away_ppg_rank = 0
      away_oppppg_rank = 0

      if @team_names[home_team]
        compare_home_team = @team_names[home_team]
        home_team_info = Team.find_by(team: compare_home_team)
        if home_team_info.timezone == 2
          addingDate = addingDate - 3.hours
          home_timezone = "PACIFIC"
        elsif home_team_info.timezone == 3
          addingDate = addingDate - 1.hours
          home_timezone = "CENTRAL"
        elsif home_team_info.timezone == 4
          addingDate = addingDate - 2.hours
          home_timezone = "MOUNTAIN"
        elsif home_team_info.timezone == 1
          home_timezone = "EASTERN"
        end
        home_win_rank = home_team_info.order_one_seventeen
        home_ppg_rank = home_team_info.order_two_seventeen
        home_oppppg_rank = home_team_info.order_thr_seventeen
      end

      if @team_names[away_team]
        compare_away_team = @team_names[away_team]
        away_team_info = Team.find_by(team: compare_away_team)
        if away_team_info.timezone == 2
          away_timezone = "PACIFIC"
        elsif away_team_info.timezone == 3
          away_timezone = "CENTRAL"
        elsif away_team_info.timezone == 4
          away_timezone = "MOUNTAIN"
        elsif away_team_info.timezone == 1
          away_timezone = "EASTERN"
        end
        away_win_rank = away_team_info.order_one_seventeen
        away_ppg_rank = away_team_info.order_two_seventeen
        away_oppppg_rank = away_team_info.order_thr_seventeen
      end
      tv_station = []
      if slice.children.size > 7
        if slice.children[3].children.size > 2
          tv_station.push('ESPN')
        else
          tv_station.push(slice.children[3].text)
        end
        tv_station.push(slice.children[4].text)
        tv_station.push(slice.children[5].text)
        game.update(tv_station: tv_station.join(','))
      end
	  	game.update(away_team: away_team, home_team: home_team, home_abbr: home_abbr, away_abbr: away_abbr, game_date: date, year: addingDate.strftime("%Y"), date: addingDate.strftime("%b %e"), time: addingDate.strftime("%I:%M%p"), est_time: date.strftime("%I:%M%p"), week: addingDate.strftime("%a"), away_mins: away_mins_value, away_fga: away_fga_value, away_fta: away_fta_value, away_toValue: away_to_value, away_orValue: away_or_value, home_mins: home_mins_value, home_fga: home_fga_value, home_fta: home_fta_value, home_toValue: home_to_value, home_orValue: home_or_value, home_timezone: home_timezone, home_win_rank: home_win_rank, home_ppg_rank: home_ppg_rank, home_oppppg_rank: home_oppppg_rank, away_timezone: away_timezone, away_win_rank: away_win_rank, away_ppg_rank: away_ppg_rank, away_oppppg_rank: away_oppppg_rank, away_stl: away_stl_value, away_blk: away_blk_value, home_stl: home_stl_value, home_blk: home_blk_value, away_pf: away_pf_value, home_pf: home_pf_value)
	  end
  end

	task :getHalf => [:environment] do
		include Api
		games = Nba.where("game_date between ? and ?", (Date.today - 2.days).beginning_of_day, Time.now-5.hours)
		puts games.size
		games.each do |game|
			game_id = game.game_id
			url = "http://www.espn.com/nba/boxscore?gameId=#{game_id}"
			doc = download_document(url)
			puts url
			game_status = doc.css(".game-time").first.text
	  		if game_status.include?("1st") || game_status.include?("2nd") || game_status.include?("Half")
		  		element = doc.css(".highlight")
		  		if element.size > 3
			  		away_value = element[0]
			  		home_value = element[2]

					away_fga_value = away_value.children[2].text
					away_fga_index = away_fga_value.index('-')
					away_fga_value = away_fga_index ? away_fga_value[away_fga_index+1..-1].to_i : 0
					away_to_value = away_value.children[11].text.to_i
          away_pf_value = away_value.children[12].text.to_i
					away_fta_value = away_value.children[4].text
					away_fta_index = away_fta_value.index('-')
					away_fta_value = away_fta_index ? away_fta_value[away_fta_index+1..-1].to_i : 0
					away_or_value = away_value.children[5].text.to_i
          away_stl_value = away_value.children[9].text.to_i
          away_blk_value = away_value.children[10].text.to_i

					home_fga_value = home_value.children[2].text
					home_fga_index = home_fga_value.index('-')
					home_fga_value = home_fga_index ? home_fga_value[home_fga_index+1..-1].to_i : 0
					home_to_value = home_value.children[11].text.to_i
          home_pf_value = home_value.children[12].text.to_i
					home_fta_value = home_value.children[4].text
					home_fta_index = home_fta_value.index('-')
					home_fta_value = home_fta_index ? home_fta_value[home_fta_index+1..-1].to_i : 0
					home_or_value = home_value.children[5].text.to_i
          home_stl_value = home_value.children[9].text.to_i
          home_blk_value = home_value.children[10].text.to_i
				end

		  		game.update(first_away_fga: away_fga_value, first_away_fta: away_fta_value, first_away_toValue: away_to_value, first_away_orValue: away_or_value, first_home_fga: home_fga_value, first_home_fta: home_fta_value, first_home_toValue: home_to_value, first_home_orValue: home_or_value, first_away_stl: away_stl_value, first_away_blk: away_blk_value, first_home_stl: home_stl_value, first_home_blk: home_blk_value, first_home_pf: home_pf_value, first_away_pf: away_pf_value)
	  		end
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
    games = Nba.where("game_count is null")
    games.each do |game|
      game_count = Nba.where('year = ? AND date = ?', game.year, game.date).size
      game.update(game_count: game_count)
    end
		puts "----------Get Link Games----------"

		Time.zone = 'Eastern Time (US & Canada)'

		games = Nba.where("game_date between ? and ?", (Date.today - 10.days).beginning_of_day, (Date.today + 5.days).end_of_day)
		puts games.size
		games.each do |game|
			home_team = game.home_team
			away_team = game.away_team
			game_date = game.game_date

			away_last_game = ""
      away_last_fly = ""
      away_last_ot = ""
			away_team_prev = Nba.where("home_team = ? AND game_date < ?", away_team, game_date).or(Nba.where("away_team = ? AND game_date < ?", away_team, game_date)).order(:game_date).last
			if away_team_prev
				away_last_game = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(away_team_prev.game_date).in_time_zone.to_date ).to_i - 1
        if away_team_prev.home_team == away_team
          away_last_fly = "YES"
        else
          away_last_fly = "NO"
        end
        if away_team_prev.away_ot_quarter != nil &&  away_team_prev.home_ot_quarter != nil
          if away_team_prev.away_ot_quarter > 0 || away_team_prev.home_ot_quarter > 0
            away_last_ot = "YES"
          else
            away_last_ot = "NO"
          end
        end
			end

			away_next_game = ""
      away_next_fly = ""
			away_team_next = Nba.where("home_team = ? AND game_date > ?", away_team, game_date).or(Nba.where("away_team = ? AND game_date > ?", away_team, game_date)).order(:game_date).first
			if away_team_next
				away_next_game = (DateTime.parse(away_team_next.game_date).in_time_zone.to_date  - DateTime.parse(game_date).in_time_zone.to_date ).to_i - 1
        if away_team_next.home_team == away_team
          away_next_fly = "YES"
        else
          away_next_fly = "NO"
        end
			end

			home_last_game = ""
			home_last_fly = ""
      home_last_ot = ""
			home_team_prev = Nba.where("home_team = ? AND game_date < ?", home_team, game_date).or(Nba.where("away_team = ? AND game_date < ?", home_team, game_date)).order(:game_date).last
			if home_team_prev
				home_last_game = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(home_team_prev.game_date).in_time_zone.to_date ).to_i - 1
				if home_team_prev.home_team == home_team
					home_last_fly = "NO"
				else
					home_last_fly = "YES"
				end
        if home_team_prev.away_ot_quarter != nil && home_team_prev.home_ot_quarter != nil
          if home_team_prev.away_ot_quarter > 0 || home_team_prev.home_ot_quarter > 0
            home_last_ot = "YES"
          else
            home_last_ot = "NO"
          end
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

      away_last_home = ""
      away_team_prev = Nba.where("home_team = ? AND game_date < ?", away_team, game_date).order(:game_date).last
      if away_team_prev
        away_last_home = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(away_team_prev.game_date).in_time_zone.to_date ).to_i - 1
      end

      away_next_home = ""
      away_team_next = Nba.where("home_team = ? AND game_date > ?", away_team, game_date).order(:game_date).first
      if away_team_next
        away_next_home = (DateTime.parse(away_team_next.game_date).in_time_zone.to_date  - DateTime.parse(game_date).in_time_zone.to_date ).to_i - 1
      end

			game.update(away_last_game: away_last_game, away_next_game: away_next_game, home_last_game: home_last_game, home_next_game: home_next_game, home_next_fly: home_next_fly, home_last_fly: home_last_fly, away_next_fly: away_next_fly, away_last_fly: away_last_fly, home_last_ot: home_last_ot, away_last_ot: away_last_ot, away_last_home: away_last_home,away_next_home: away_next_home )
		end
	end

  task :filterNba => :environment do
    filters = [
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
        [true, true, false, false, true, true, true, true],
        [true, true, true, true, false, false, true, true],
        [false, false, true, true, true, true, false, false],
        [true, true, false, false, false, false, true, true],
        [true, true, true, true, false, false, false, false],
        [false, false, false, false, true, true, true, true],
        [false, true, false, true, true, false, true, false]
    ]
    games = Nba.where("game_date between ? and ?", Date.yesterday.beginning_of_day, Date.tomorrow.end_of_day)
    puts games.size
    games.each do |game|
      filters.each_with_index do |filter, index|
        search_string = []
        search_second_string = []
        first_one = []
        if filter[0]
          search_string.push("awaylastfly = '#{game.away_last_fly}'")
          search_second_string.push("awaylastfly = '#{game.away_last_fly}'")
          first_one.push(game.away_last_fly[0])
        else
          search_string.push("awaylastfly <> '#{game.away_last_fly}'")
          first_one.push("ANY")
        end
        if filter[1]
          search_string.push("awaynextfly = '#{game.away_next_fly}'")
          search_second_string.push("awaynextfly = '#{game.away_next_fly}'")
          first_one.push(game.away_next_fly[0])
        else
          search_string.push("awaynextfly <> '#{game.away_next_fly}'")
          first_one.push("ANY")
        end
        if filter[2]
          search_string.push("roadlast = '#{game.away_last_game}'")
          search_second_string.push("roadlast = '#{game.away_last_game}'")
          first_one.push(game.away_last_game)
        else
          search_string.push("roadlast <> '#{game.away_last_game}'")
          first_one.push("ANY")
        end
        if filter[3]
          search_string.push("roadnext = '#{game.away_next_game}'")
          search_second_string.push("roadnext = '#{game.away_next_game}'")
          first_one.push(game.away_next_game)
        else
          search_string.push("roadnext <> '#{game.away_next_game}'")
          first_one.push("ANY")
        end
        if filter[4]
          search_string.push("homenext = '#{game.home_next_game}'")
          search_second_string.push("homenext = '#{game.home_next_game}'")
          first_one.push(game.home_next_game)
        else
          search_string.push("homenext <> '#{game.home_next_game}'")
          first_one.push("ANY")
        end
        if filter[5]
          search_string.push("homelast = '#{game.home_last_game}'")
          search_second_string.push("homelast = '#{game.home_last_game}'")
          first_one.push(game.home_last_game)
        else
          search_string.push("homelast <> '#{game.home_last_game}'")
          first_one.push("ANY")
        end
        if filter[6]
          search_string.push("homenextfly = '#{game.home_next_fly}'")
          search_second_string.push("homenextfly = '#{game.home_next_fly}'")
          first_one.push(game.home_next_fly[0])
        else
          search_string.push("homenextfly <> '#{game.home_next_fly}'")
          first_one.push("ANY")
        end
        if filter[7]
          search_string.push("homelastfly = '#{game.home_last_fly}'")
          search_second_string.push("homelastfly = '#{game.home_last_fly}'")
          first_one.push(game.home_last_fly[0])
        else
          search_string.push("homelastfly <> '#{game.home_last_fly}'")
          first_one.push("ANY")
        end
        first_one = first_one.join("-")
        search_string = search_string.join(" AND ")
        search_second_string = search_second_string.join(" AND ")
        filter_element = Fullseason.where(search_string)
        filter_second_element = Fullseason.where(search_second_string)
        filter_element_source = filter_element.dup
        filter_second_element_source = filter_second_element.dup

        # 2000-2017 - 2008
        # 2010-2017 - 2009
        # 2010-2011 - 2010
        # 2011-2012 - 2011
        # 2012-2013 - 2012
        # 2013-2014 - 2013
        # 2014-2015 - 2014
        # 2015-2016 - 2015
        # 2016-2017 - 2016
        # 2017-2018 - 2017
        # 2018-2019 - 2018
        (2008...2019).each do |year|
          filter_data = Filter.find_or_create_by(nba_id: game.id, index: index, year: year)
          if year === 2008
            filter_element = filter_element_source.where('id >= 107399 AND id <= 127852')
            filter_second_element = filter_second_element_source.where('id >= 107399 AND id <= 127852')
          elsif year === 2009
            filter_element = filter_element_source.where('id >= 120710 AND id <= 127852').or(filter_element_source.where('id >= 107399 AND id <= 108629'))
            filter_second_element = filter_second_element_source.where('id >= 120710 AND id <= 127852').or(filter_second_element_source.where('id >= 107399 AND id <= 108629'))
          elsif year === 2010
            filter_element = filter_element_source.where('id >= 120710 AND id <= 121940')
            filter_second_element = filter_second_element_source.where('id >= 120710 AND id <= 121940')
          elsif year === 2011
            filter_element = filter_element_source.where('id >= 121941 AND id <= 122931')
            filter_second_element = filter_second_element_source.where('id >= 121941 AND id <= 122931')
          elsif year === 2012
            filter_element = filter_element_source.where('id >= 122932 AND id <= 124161')
            filter_second_element = filter_second_element_source.where('id >= 122932 AND id <= 124161')
          elsif year === 2013
            filter_element = filter_element_source.where('id >= 124162 AND id <= 125390')
            filter_second_element = filter_second_element_source.where('id >= 124162 AND id <= 125390')
          elsif year === 2014
            filter_element = filter_element_source.where('id >= 125391 AND id <= 126621')
            filter_second_element = filter_second_element_source.where('id >= 125391 AND id <= 126621')
          elsif year === 2015
            filter_element = filter_element_source.where('id >= 126622 AND id <= 127852')
            filter_second_element = filter_second_element_source.where('id >= 126622 AND id <= 127852')
          elsif year === 2016
            filter_element = filter_element_source.where('id >= 107399 AND id <= 108629')
            filter_second_element = filter_second_element_source.where('id >= 107399 AND id <= 108629')
          elsif year === 2017
            filter_element = filter_element_source.where('id >= 127853 AND id <= 129085')
            filter_second_element = filter_second_element_source.where('id >= 127853 AND id <= 129085')
          elsif year === 2018
            filter_element = filter_element_source.where('id >= 129086')
            filter_second_element = filter_second_element_source.where('id >= 129086')
          end

          result_element = {
              first_one: first_one,
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
              full_under: filter_second_element.where("totalou = 'under'").count,
              full_over: filter_second_element.where("totalou = 'over'").count,
              first_half_away: filter_second_element.where("first_half_bigger = 'AWAY'").count,
              first_half_home: filter_second_element.where("first_half_bigger = 'HOME'").count,
              second_half_away: filter_second_element.where("second_half_bigger = 'AWAY'").count,
              second_half_home: filter_second_element.where("second_half_bigger = 'HOME'").count,
              full_half_away: filter_second_element.where("fullgame_bigger = 'AWAY'").count,
              full_half_home: filter_second_element.where("fullgame_bigger = 'HOME'").count
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
          end
          filter_data.update(result_element)
        end

      end
    end
  end

  # For Excel file
  task :tvstation => [:environment] do
    include Api
    games = Nba.all
    index_date = Date.today
    while index_date >= Date.new(2018, 12, 12)  do
      game_day = index_date.strftime("%Y%m%d")
      index_date = index_date - 1.days
      puts game_day
      url = "https://classic.sportsbookreview.com/betting-odds/nba-basketball/1st-half/?date=#{game_day}"
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

        home_name     = element.children[0].children[5].children[1].text
        away_name     = element.children[0].children[5].children[0].text
        home_number   = element.children[0].children[3].children[2].text
        away_number   = element.children[0].children[3].children[1].text
        tv_station    = ''
        tv_station    = element.children[0].children[6].children[0].text if element.children[0].children[6].children.size > 0
        tv_station    = tv_station + "," + element.children[0].children[6].children[1].text if element.children[0].children[6].children.size > 1
        
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

        matched = games.select{|field| ((field.home_team.include?(home_name) && field.away_team.include?(away_name)) || (field.home_team.include?(away_name) && field.away_team.include?(home_name))) && (date == field.game_date) }
        if matched.size > 0
          update_game = matched.first
          update_game.update(tv_station: tv_station)
        end
      end
    end
  end

  task :getFiltervalue => :environment do
    games = Nba.where("game_date between ? and ?", Date.new(2018, 12, 5).beginning_of_day, Date.new(2018, 12, 22).beginning_of_day)
    # games = Nba.where('fg_total_count_2000 is null')
    games.each do |game|
      countItem = Fullseason.where("awaylastfly = ? AND awaynextfly = ? AND roadlast = ? AND roadnext = ? AND homenext = ? AND homelast = ? AND homenextfly = ? AND homelastfly = ? AND id != ?", game.away_last_fly, game.away_next_fly, game.away_last_game, game.away_next_game, game.home_next_game, game.home_last_game, game.home_next_fly, game.home_last_fly, (game.id.to_i + 107398))
      secondItem = Secondtravel.where("awaylastfly = ? AND awaynextfly = ? AND roadlast = ? AND roadnext = ? AND homenext = ? AND homelast = ? AND homenextfly = ? AND homelastfly = ?", game.away_last_fly, game.away_next_fly, game.away_last_game, game.away_next_game, game.home_next_game, game.home_last_game, game.home_next_fly, game.home_last_fly)

      roadtotal = countItem.average(:roadfirsthalf).to_f + countItem.average(:roadthird).to_f + countItem.average(:roadforth).to_f
      hometotal = countItem.average(:homefirsthalf).to_f + countItem.average(:homethird).to_f + countItem.average(:homeforth).to_f

      fg_road_2000 = roadtotal.round(2)
      fg_home_2000 = hometotal.round(2)
      fg_diff_2000 = (roadtotal - hometotal).round(2)
      fg_count_2000 = countItem.count(:totalpoint).to_i

      roadtotal = secondItem.average(:roadfirsthalf).to_f + secondItem.average(:roadthird).to_f + secondItem.average(:roadforth).to_f
      hometotal = secondItem.average(:homefirsthalf).to_f + secondItem.average(:homethird).to_f + secondItem.average(:homeforth).to_f

      fg_road_1990 = roadtotal.round(2)
      fg_home_1990 = hometotal.round(2)
      fg_diff_1990 = (roadtotal - hometotal).round(2)
      fg_count_1990 = secondItem.count(:totalpoint).to_i

      first_half_road_2000 = countItem.average(:roadfirsthalf).to_f.round(2)
      first_half_home_2000 = countItem.average(:homefirsthalf).to_f.round(2)
      first_half_diff_2000 = (countItem.average(:roadfirsthalf).to_f - countItem.average(:homefirsthalf).to_f).round(2)
      first_half_count_2000 = countItem.count(:roadfirsthalf).to_i

      first_half_road_1990 = secondItem.average(:roadfirsthalf).to_f.round(2)
      first_half_home_1990 = secondItem.average(:homefirsthalf).to_f.round(2)
      first_half_diff_1990 = (secondItem.average(:roadfirsthalf).to_f - secondItem.average(:homefirsthalf).to_f).round(2)
      first_half_count_1990 = secondItem.count(:roadfirsthalf).to_i

      second_half_road_2000 = (countItem.average(:roadthird).to_f + countItem.average(:roadforth).to_f).round(2)
      second_half_home_2000 = (countItem.average(:homethird).to_f + countItem.average(:homeforth).to_f).round(2)
      second_half_diff_2000 = (countItem.average(:roadthird).to_f + countItem.average(:roadforth).to_f - countItem.average(:homethird).to_f - countItem.average(:homeforth).to_f).round(2)
      second_half_count_2000 = countItem.count(:roadthird).to_i

      second_half_road_1990 = (secondItem.average(:roadthird).to_f + secondItem.average(:roadforth).to_f).round(2)
      second_half_home_1990 = (secondItem.average(:homethird).to_f + secondItem.average(:homeforth).to_f).round(2)
      second_half_diff_1990 = (secondItem.average(:roadthird).to_f + secondItem.average(:roadforth).to_f - secondItem.average(:homethird).to_f - secondItem.average(:homeforth).to_f).round(2)
      second_half_count_1990 = secondItem.count(:roadthird).to_i

      fg_total_pt_2000 = countItem.where("fglinetotal is not null AND fglinetotal != 0").average(:totalpoint).to_f.round(2)
      fg_total_line_2000 = countItem.where("fglinetotal is not null AND fglinetotal != 0").average(:fglinetotal).to_f.round(2)
      fg_total_diff_2000 = (fg_total_pt_2000 - fg_total_line_2000).round(2)
      first_half_total_pt_2000 = countItem.where("firstlinetotal is not null AND firstlinetotal != 0").average(:firstpoint).to_f.round(2)
      first_half_total_line_2000 = countItem.where("firstlinetotal is not null AND firstlinetotal != 0").average(:firstlinetotal).to_f.round(2)
      first_half_total_diff_2000 = (first_half_total_pt_2000 - first_half_total_line_2000).round(2)
      second_half_total_pt_2000 = countItem.where("secondlinetotal is not null AND secondlinetotal != 0").average(:secondpoint).to_f.round(2)
      second_half_total_line_2000 = countItem.where("secondlinetotal is not null AND secondlinetotal != 0").average(:secondlinetotal).to_f.round(2)
      second_half_total_diff_2000 = (second_half_total_pt_2000 - second_half_total_line_2000).round(2)

      fg_total_count_2000 = countItem.where("fglinetotal is not null AND fglinetotal != 0").count(:fglinetotal).to_i
      first_half_total_count_2000 = countItem.where("firstlinetotal is not null AND firstlinetotal != 0").count(:firstlinetotal).to_i
      second_half_total_count_2000 = countItem.where("secondlinetotal is not null AND secondlinetotal != 0").count(:secondlinetotal).to_i

      first_half_bigger = "0"
      first_half_difference = game.away_first_quarter.to_f + game.away_second_quarter.to_f - game.home_first_quarter.to_f - game.home_second_quarter.to_f - game.first_closer_side.to_f
      if first_half_difference > 0
        first_half_bigger = "AWAY"
      elsif first_half_difference < 0
        first_half_bigger = "HOME"
      else
        first_half_bigger = "0"
      end

      second_half_bigger = "0"
      second_half_difference = game.away_third_quarter.to_f + game.away_forth_quarter.to_f - game.home_third_quarter.to_f - game.home_forth_quarter.to_f - game.second_closer_side.to_f
      if second_half_difference > 0
        second_half_bigger = "AWAY"
      elsif second_half_difference < 0
        second_half_bigger = "HOME"
      else
        second_half_bigger = "0"
      end

      fullgame_bigger = "0"
      fullgame_difference = game.away_score.to_f - game.home_score.to_f - game.full_closer_side.to_f
      if fullgame_difference > 0
        fullgame_bigger = "AWAY"
      elsif fullgame_difference < 0
        fullgame_bigger = "HOME"
      else
        fullgame_bigger = "0"
      end

      game.update(
          fg_road_2000: fg_road_2000,
          fg_home_2000: fg_home_2000,
          fg_diff_2000: fg_diff_2000,
          fg_count_2000: fg_count_2000,
          fg_road_1990: fg_road_1990,
          fg_home_1990: fg_home_1990,
          fg_diff_1990: fg_diff_1990,
          fg_count_1990: fg_count_1990,
          first_half_road_2000: first_half_road_2000,
          first_half_home_2000: first_half_home_2000,
          first_half_diff_2000: first_half_diff_2000,
          first_half_count_2000: first_half_count_2000,
          first_half_road_1990: first_half_road_1990,
          first_half_home_1990: first_half_home_1990,
          first_half_diff_1990: first_half_diff_1990,
          first_half_count_1990: first_half_count_1990,
          second_half_road_2000: second_half_road_2000,
          second_half_home_2000: second_half_home_2000,
          second_half_diff_2000: second_half_diff_2000,
          second_half_count_2000: second_half_count_2000,
          second_half_road_1990: second_half_road_1990,
          second_half_home_1990: second_half_home_1990,
          second_half_diff_1990: second_half_diff_1990,
          second_half_count_1990: second_half_count_1990,
          fg_total_pt_2000: fg_total_pt_2000,
          fg_total_line_2000: fg_total_line_2000,
          fg_total_diff_2000: fg_total_diff_2000,
          first_half_total_pt_2000: first_half_total_pt_2000,
          first_half_total_line_2000: first_half_total_line_2000,
          first_half_total_diff_2000: first_half_total_diff_2000,
          second_half_total_pt_2000: second_half_total_pt_2000,
          second_half_total_line_2000: second_half_total_line_2000,
          second_half_total_diff_2000: second_half_total_diff_2000,
          fg_total_count_2000: fg_total_count_2000,
          first_half_total_count_2000: first_half_total_count_2000,
          second_half_total_count_2000: second_half_total_count_2000,
          first_half_bigger: first_half_bigger,
          second_half_bigger: second_half_bigger,
          fullgame_bigger: fullgame_bigger
      )
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
			url = "https://classic.sportsbookreview.com/betting-odds/nba-basketball/1st-half/?date=#{game_day}"
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

				score_element = element.children[0].children[11]

				if score_element.children[1].text == ""
					score_element = element.children[0].children[9]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[13]
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
					update_game.update(first_opener_side: opener_side, first_closer_side: closer_side)
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
		
	task :getSecondLines, [:type, :game_link] => [:environment] do |t, args|
		include Api
		games = Nba.all
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

				if score_element.children[1].text == ""
					score_element = element.children[0].children[9]
				end

				if score_element.children[1].text == ""
					score_element = element.children[0].children[13]
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
					if type == "second"
						puts opener_side
						puts closer_side
						update_game.update(second_opener_side: opener_side, second_closer_side: closer_side)
					elsif type == "full"
						puts opener_side
						puts closer_side
						update_game.update(full_opener_side: opener_side, full_closer_side: closer_side)
					elsif type == "firstTotal"
						puts opener_side
						puts closer_side
						update_game.update(first_opener_total: opener_side, first_closer_total: closer_side)
					elsif type == "secondTotal"
						puts opener_side
						puts closer_side
						update_game.update(second_opener_total: opener_side, second_closer_total: closer_side)
					elsif type == "fullTotal"
						puts opener_side
						puts closer_side
						update_game.update(full_opener_total: opener_side, full_closer_total: closer_side)
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

				if slice.children[0].children.size > 1
					player_name = slice.children[0].children[0].children[0].text
					link = slice.children[0].children[0]['href']
					puts link
					page = download_document(link)
          height = page.css(".general-info")[0]
          if height.children[1]
            height = height.children[1].text
          else
            height = nil
          end
          birthdate = page.css(".player-metadata")[0]
          if birthdate.children[0]
            birthdate = birthdate.children[0].children[1].text
          else
            birthdate = nil
          end
				else
					player_name = slice.children[0].text
					link = ""
					height = 0
          birthdate = ""
				end
				position = ""
        if slice.children[0].children.size > 1
          position = slice.children[0].children[1].text
        end
        mins_value = 0
        fga_value = 0
        to_value = 0
        pts_value = 0
        fta_value = 0
        or_value = 0
        stl_value = 0
        blk_value = 0
        pf_value = 0
        poss = 0
        if slice.children.size > 14
          mins_value = slice.children[1].text.to_i
          fga_value = slice.children[2].text
          fga_index = fga_value.index('-')
          fga_value = fga_index ? fga_value[fga_index+1..-1].to_i : 0
          to_value = slice.children[11].text.to_i
          pts_value = slice.children[14].text.to_i
          fta_value = slice.children[4].text
          fta_index = fta_value.index('-')
          fta_value = fta_index ? fta_value[fta_index+1..-1].to_i : 0
          or_value = slice.children[5].text.to_i
          stl_value = slice.children[9].text.to_i
          blk_value = slice.children[10].text.to_i
          pf_value = slice.children[12].text.to_i
          poss = fga_value + to_value + (fta_value * 0.44) - or_value
        end
				unless player = game.players.find_by(player_name: player_name, team_abbr: team_abbr)
         	player = game.players.create(player_name: player_name, team_abbr: team_abbr)
        end
        player.update(position: position, state: index + 1, poss: poss, mins: mins_value, fga: fga_value, fta:fta_value, toValue: to_value, orValue: or_value, stlValue:stl_value, blkValue:blk_value, height: height, birthdate: birthdate, link: link, game_date: game.game_date, ptsValue: pts_value, pfValue: pf_value )
			end

			home_players = doc.css('#gamepackage-boxscore-module .gamepackage-home-wrap tbody tr')
			team_abbr = 1
			end_index = home_players.size - 2
			(0..end_index).each_with_index do |element, index|
				slice = home_players[element]
				if slice.children[0].children.size > 1
					player_name = slice.children[0].children[0].children[0].text
					link = slice.children[0].children[0]['href']
					puts link
					page = download_document(link)
					height = page.css(".general-info")[0]
          if height.children[1]
            height = height.children[1].text
          else
            height = nil
          end
          birthdate = page.css(".player-metadata")[0]
          if birthdate.children[0]
            birthdate = birthdate.children[0].children[1].text
          else
            birthdate = nil
          end
				else
					player_name = slice.children[0].text
					link = ""
					height = 0
          birthdate = ""
				end
				position = ""
				if slice.children[0].children.size > 1
					position = slice.children[0].children[1].text
				end
        mins_value = 0
        fga_value = 0
        to_value = 0
        pts_value = 0
        fta_value = 0
        or_value = 0
        stl_value = 0
        blk_value = 0
        pf_value = 0
        poss = 0
        if slice.children.size > 14
          mins_value = slice.children[1].text.to_i
          fga_value = slice.children[2].text
          fga_index = fga_value.index('-')
          fga_value = fga_index ? fga_value[fga_index+1..-1].to_i : 0
          to_value = slice.children[11].text.to_i
          pts_value = slice.children[14].text.to_i
          fta_value = slice.children[4].text
          fta_index = fta_value.index('-')
          fta_value = fta_index ? fta_value[fta_index+1..-1].to_i : 0
          or_value = slice.children[5].text.to_i
          stl_value = slice.children[9].text.to_i
          blk_value = slice.children[10].text.to_i
          pf_value = slice.children[12].text.to_i
          poss = fga_value + to_value + (fta_value * 0.44) - or_value
        end
				unless player = game.players.find_by(player_name: player_name, team_abbr: team_abbr)
         	player = game.players.create(player_name: player_name, team_abbr: team_abbr)
        end
        player.update(position: position, state: index + 1, poss: poss, mins: mins_value, fga: fga_value, fta:fta_value, toValue: to_value, orValue: or_value, stlValue:stl_value, blkValue:blk_value, height: height, birthdate: birthdate, link: link, game_date: game.game_date,  ptsValue: pts_value, pfValue: pf_value )
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
          player_link = player.children[1].children[0]['href']
					player_index = player_name.rindex(' ')
					player_name = player_index ? player_name[0] + ". " + player_name[player_index+1..-1] : ""
          count = player.children[3].children[0].text.to_i
					ortg = player.children[28].text
					drtg = player.children[29].text
					unless player_element = Tg.find_by(player_name: player_name, team_abbr: team_abbr, year: year)
           	player_element = Tg.create(player_name: player_name, team_abbr: team_abbr, year: year)
          end
          player_fullname = player.children[1].children[0].text
          player_fullname = player_fullname.gsub('.', '')
		      player_element.update(ortg: ortg, drtg: drtg, count: count, player_link: player_link, player_fullname: player_fullname)
				end
				if index == 1
					break
				end
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
        sum_or = 0
        sum_stl = 0
        sum_to = 0
        sum_blk = 0
        sum_pf = 0
				count = 0
				mins_min = 100
				mins_max = 0
				last_players = Player.where("game_date <= '" + player.game_date + "' AND link like '" + player.link + "%'").order('game_date DESC')
				last_players.each do |last_player|
					if count == 10
						break
					end
          if last_player.mins == 0
            next
          end
					possession.push(last_player.nba_id)
					sum_poss = sum_poss + last_player.poss
					sum_mins = sum_mins + last_player.mins
          sum_or = sum_or + last_player.orValue
          sum_stl = sum_stl + last_player.stlValue if last_player.stlValue
          sum_to = sum_to + last_player.toValue if last_player.toValue
          sum_blk = sum_blk + last_player.blkValue if last_player.blkValue
          sum_pf = sum_pf + last_player.pfValue if last_player.pfValue

          mins_min = last_player.mins if mins_min > last_player.mins
          mins_max = last_player.mins if mins_max < last_player.mins
					last_team = Player.where("nba_id = ? AND team_abbr = ? AND player_name = ?",last_player.nba_id, last_player.team_abbr, "TEAM")
					team_poss = team_poss + last_team.first.poss
					count = count + 1
				end
				sum_mins = sum_mins - mins_min - mins_max
        if sum_mins < 0
          sum_mins = 0
        end
				player.update(sum_poss: sum_poss, team_poss: team_poss, possession: possession.join(","), sum_mins: sum_mins, sum_blk: sum_blk, sum_or: sum_or, sum_stl: sum_stl, sum_pf: sum_pf, sum_to: sum_to)
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
          if player.player_name === 'A. HarrisonA. Harrison'
            player.update(
                player_name: 'A. Harriso',
                link: 'http://www.espn.com/nba/player/_/id/3064511'
            )
          end
          player_name = player.player_name
          url = player.link
          puts player_name
          puts url
          doc = download_document(url)
          player_name = doc.css('h1').first.text

					player_name_index = player_name.index(" Jr.")
					player_name = player_name_index ? player_name[0..player_name_index-1] : player_name

					player_name_index = player_name.index(" II")
					player_name = player_name_index ? player_name[0..player_name_index-1] : player_name

					player_name_index = player_name.index(" III")
					player_name = player_name_index ? player_name[0..player_name_index-1] : player_name

          player_name_index = player_name.index(" IV")
          player_name = player_name_index ? player_name[0..player_name_index-1] : player_name

          player_name = player_name.gsub('.', '')

					# if @player_name[player_name]
					# 	player_name = @player_name[player_name]
					# end
       
          if @player_another_name[player_name]
            player_name = @player_another_name[player_name]
          end
					
					ortg = 0
					drtg = 0
          count = 0
          player_link = ""
          player_fullname = ""
          player_elements = Tg.where("player_fullname = ? AND year >= 2018", player_name)
          player_elements.each do |player_element|
            player_count = (player_element.count != 0) ? player_element.count : 1
            count = count + player_count
            ortg = ortg + player_count * (player_element.ortg ? player_element.ortg : 0)
            drtg = drtg + player_count * (player_element.drtg ? player_element.drtg : 0)
            player_link = player_element.player_link
            player_fullname = player_element.player_fullname
          end
          count = 1 if count == 0
					ortg = (ortg.to_f / count).round(2)
					drtg = (drtg.to_f / count).round(2)
					player.update(ortg: ortg, drtg: drtg, player_link: player_link, player_fullname: player_name)
				end
			end
		end
	end

  task :getCompare => [:environment] do
    include Api
    games = Nba.where("game_date between ? and ?", (Date.today - 2.days).beginning_of_day, (Date.today + 2.days).end_of_day)
    puts games.size
    games.each do |game|
      home_abbr = game.home_abbr
      away_abbr = game.away_abbr
      next unless home_abbr
      next unless away_abbr

      now = Date.strptime(game.game_date)
      if now > Time.now
        now = Time.now
      end

      away_last = Nba.where("home_abbr = ? AND game_date < ?", away_abbr, now).or(Nba.where("away_abbr = ? AND game_date < ?", away_abbr, now)).order(:game_date).last
      home_last = Nba.where("home_abbr = ? AND game_date < ?", home_abbr, now).or(Nba.where("away_abbr = ? AND game_date < ?", home_abbr, now)).order(:game_date).last
      
      if away_abbr == away_last.away_abbr
        away_flag = 0
      else
        away_flag = 1
      end

      if home_abbr == home_last.away_abbr
        home_flag = 0
      else
        home_flag = 1
      end

      home_pg_players = home_last.players.where("team_abbr = ? AND position = 'PG' AND player_name <> 'TEAM' AND player_link <> ''", home_flag).order(:state)
      away_pg_players = away_last.players.where("team_abbr = ? AND position = 'PG' AND player_name <> 'TEAM' AND player_link <> ''", away_flag).order(:state)
      home_pg_players.each_with_index do |home_pg_player, index|
        if index == 3
          break
        end
        unless home_pg_player.player_fullname
          next
        end
        if home_pg_player.player_fullname == ""
          next
        end
        away_pg_players.each_with_index do |away_pg_player, index|
          if index == 3
            break
          end
          unless away_pg_player.player_fullname
            next
          end
          if away_pg_player.player_fullname == ""
            next
          end
          Rake::Task["nba:getOnebyOne"].invoke(game, home_pg_player, away_pg_player)
          Rake::Task["nba:getOnebyOne"].reenable
        end
      end

      home_pg_players = home_last.players.where("team_abbr = ? AND position = 'SG' AND player_name <> 'TEAM' AND player_link <> ''", home_flag).order(:state)
      away_pg_players = away_last.players.where("team_abbr = ? AND position = 'SG' AND player_name <> 'TEAM' AND player_link <> ''", away_flag).order(:state)
      home_pg_players.each_with_index do |home_pg_player, index|
        if index == 3
          break
        end
        unless home_pg_player.player_fullname
          next
        end
        if home_pg_player.player_fullname == ""
          next
        end
        away_pg_players.each_with_index do |away_pg_player, index|
          if index == 3
            break
          end
          unless away_pg_player.player_fullname
            next
          end
          if away_pg_player.player_fullname == ""
            next
          end
          Rake::Task["nba:getOnebyOne"].invoke(game, home_pg_player, away_pg_player)
          Rake::Task["nba:getOnebyOne"].reenable
        end
      end

      home_pg_players = home_last.players.where("team_abbr = ? AND position = 'PF' AND player_name <> 'TEAM' AND player_link <> ''", home_flag).or(home_last.players.where("team_abbr = ? AND position = 'C' AND player_name <> 'TEAM' AND player_link <> ''", home_flag).or(home_last.players.where("team_abbr = ? AND position = 'SF' AND player_name <> 'TEAM' AND player_link <> ''", home_flag))).order(:state)
      away_pg_players = away_last.players.where("team_abbr = ? AND position = 'PF' AND player_name <> 'TEAM' AND player_link <> ''", away_flag).or(away_last.players.where("team_abbr = ? AND position = 'C' AND player_name <> 'TEAM' AND player_link <> ''", away_flag).or(away_last.players.where("team_abbr = ? AND position = 'SF' AND player_name <> 'TEAM' AND player_link <> ''", away_flag))).order(:state)
      home_pg_players.each_with_index do |home_pg_player, index|  
        if index == 3
          break
        end
        unless home_pg_player.player_fullname
          next
        end
        if home_pg_player.player_fullname == ""
          next
        end
        away_pg_players.each_with_index do |away_pg_player, index|
          if index == 3
            break
          end
          unless away_pg_player.player_fullname
            next
          end
          if away_pg_player.player_fullname == ""
            next
          end
          Rake::Task["nba:getOnebyOne"].invoke(game, home_pg_player, away_pg_player)
          Rake::Task["nba:getOnebyOne"].reenable
        end
      end
    end
  end

  task :getOnebyOne, [:game, :home_pg_player, :away_pg_player] => [:environment] do |t, args|
    include Api
    game = args[:game]
    home_pg_player = args[:home_pg_player]
    away_pg_player = args[:away_pg_player]


    
    home_full_name = home_pg_player.player_fullname
    home_full_name_link = home_full_name.gsub(' ', '+')
    player_link = home_pg_player.player_link
    player_link_end = player_link.rindex(".")
    player_link_start = player_link.rindex("/")
    return unless player_link_end && player_link_start
    player_link = player_link[player_link_start+1..player_link_end-1]
    home_link = player_link
    away_full_name = away_pg_player.player_fullname
    away_full_name_link = away_full_name.gsub(' ', '+')
    player_link = away_pg_player.player_link
    player_link_end = player_link.rindex(".")
    player_link_start = player_link.rindex("/")
    return unless player_link_end && player_link_start
    player_link = player_link[player_link_start+1..player_link_end-1]
    away_link = player_link
    url = "https://www.basketball-reference.com/play-index/h2h_finder.cgi?request=1&player_id1_hint=#{home_full_name_link}&player_id1_select=#{home_full_name_link}&player_id1=#{home_link}&idx=players&player_id2_hint=#{away_full_name_link}&player_id2_select=#{away_full_name_link}&player_id2=#{away_link}&idx=players"


    doc = download_document(url)
    elements = doc.css('#all_stats tbody tr')
    if elements.size != 0
      unless compare = game.compares.find_by(home_player_name: home_full_name, home_link: home_link, away_full_name: away_full_name, away_link: away_link)
        compare = game.compares.create(home_player_name: home_full_name, home_link: home_link, away_full_name: away_full_name, away_link: away_link)
      end
      home_element = elements[0]
      away_element = elements[1]
      if home_element.children[0].text != home_full_name
        home_element = elements[1]
        away_element = elements[0]
      end
      head_home_player_name = home_element.children[0].text
      head_away_player_name = away_element.children[0].text
      head_home_player_gp = home_element.children[1].text
      head_away_player_gp = away_element.children[1].text
      head_home_player_gs = home_element.children[4].text
      head_away_player_gs = away_element.children[4].text
      head_home_player_mp = home_element.children[5].text
      head_away_player_mp = away_element.children[5].text
      head_home_player_fg = home_element.children[6].text
      head_away_player_fg = away_element.children[6].text
      head_home_player_fga = home_element.children[7].text
      head_away_player_fga = away_element.children[7].text
      head_home_player_p = home_element.children[9].text
      head_away_player_p = away_element.children[9].text
      head_home_player_pa = home_element.children[10].text
      head_away_player_pa = away_element.children[10].text
      head_home_player_ft = home_element.children[12].text
      head_away_player_ft = away_element.children[12].text
      head_home_player_fta = home_element.children[13].text
      head_away_player_fta = away_element.children[13].text
      head_home_player_orb = home_element.children[15].text
      head_away_player_orb = away_element.children[15].text
      head_home_player_stl = home_element.children[19].text
      head_away_player_stl = away_element.children[19].text
      head_home_player_blk = home_element.children[20].text
      head_away_player_blk = away_element.children[20].text
      head_home_player_tov = home_element.children[21].text
      head_away_player_tov = away_element.children[21].text
      head_home_player_pts = home_element.children[23].text
      head_away_player_pts = away_element.children[23].text
      first_home_player_name = ""
      first_home_player_age = ""
      first_home_player_gp = ""
      first_home_player_gs = ""
      first_home_player_mp = ""
      first_home_player_fg = ""
      first_home_player_fga = ""
      first_home_player_p = ""
      first_home_player_pa = ""
      first_home_player_ft = ""
      first_home_player_fta = ""
      first_home_player_orb = ""
      first_home_player_stl = ""
      first_home_player_blk = ""
      first_home_player_tov = ""
      first_home_player_pts = ""
      second_home_player_name = ""
      second_home_player_age = ""
      second_home_player_gp = ""
      second_home_player_gs = ""
      second_home_player_mp = ""
      second_home_player_fg = ""
      second_home_player_fga = ""
      second_home_player_p = ""
      second_home_player_pa = ""
      second_home_player_ft = ""
      second_home_player_fta = ""
      second_home_player_orb = ""
      second_home_player_stl = ""
      second_home_player_blk = ""
      second_home_player_tov = ""
      second_home_player_pts = ""
      first_away_player_name = ""
      first_away_player_age = ""
      first_away_player_gp = ""
      first_away_player_gs = ""
      first_away_player_mp = ""
      first_away_player_fg = ""
      first_away_player_fga = ""
      first_away_player_p = ""
      first_away_player_pa = ""
      first_away_player_ft = ""
      first_away_player_fta = ""
      first_away_player_orb = ""
      first_away_player_stl = ""
      first_away_player_blk = ""
      first_away_player_tov = ""
      first_away_player_pts = ""
      second_away_player_name = ""
      second_away_player_age = ""
      second_away_player_gp = ""
      second_away_player_gs = ""
      second_away_player_mp = ""
      second_away_player_fg = ""
      second_away_player_fga = ""
      second_away_player_p = ""
      second_away_player_pa = ""
      second_away_player_ft = ""
      second_away_player_fta = ""
      second_away_player_orb = ""
      second_away_player_stl = ""
      second_away_player_blk = ""
      second_away_player_tov = ""
      second_away_player_pts = ""

      third_home_player_age = ""
      third_home_player_gp = ""
      third_home_player_gs = ""
      third_home_player_mp = ""
      third_home_player_fg = ""
      third_home_player_fga = ""
      third_home_player_p = ""
      third_home_player_pa = ""
      third_home_player_ft = ""
      third_home_player_fta = ""
      third_home_player_orb = ""
      third_home_player_stl = ""
      third_home_player_blk = ""
      third_home_player_tov = ""
      third_home_player_pts = ""
      
      third_away_player_age = ""
      third_away_player_gp = ""
      third_away_player_gs = ""
      third_away_player_mp = ""
      third_away_player_fg = ""
      third_away_player_fga = ""
      third_away_player_p = ""
      third_away_player_pa = ""
      third_away_player_ft = ""
      third_away_player_fta = ""
      third_away_player_orb = ""
      third_away_player_stl = ""
      third_away_player_blk = ""
      third_away_player_tov = ""
      third_away_player_pts = ""

      forth_home_player_age = ""
      forth_home_player_gp = ""
      forth_home_player_gs = ""
      forth_home_player_mp = ""
      forth_home_player_fg = ""
      forth_home_player_fga = ""
      forth_home_player_p = ""
      forth_home_player_pa = ""
      forth_home_player_ft = ""
      forth_home_player_fta = ""
      forth_home_player_orb = ""
      forth_home_player_stl = ""
      forth_home_player_blk = ""
      forth_home_player_tov = ""
      forth_home_player_pts = ""
      
      forth_away_player_age = ""
      forth_away_player_gp = ""
      forth_away_player_gs = ""
      forth_away_player_mp = ""
      forth_away_player_fg = ""
      forth_away_player_fga = ""
      forth_away_player_p = ""
      forth_away_player_pa = ""
      forth_away_player_ft = ""
      forth_away_player_fta = ""
      forth_away_player_orb = ""
      forth_away_player_stl = ""
      forth_away_player_blk = ""
      forth_away_player_tov = ""
      forth_away_player_pts = ""

      url = "https://www.basketball-reference.com#{home_pg_player.player_link}"

      doc = download_document(url)
      elements = doc.css('#all_per_game tbody tr')
      first_flag = true
      second_flag = true
      third_flag = true
      forth_flag = true
      elements.each do |element|
        if element.children[0].text == '2014-15' && forth_flag
          forth_flag = false
          forth_home_player_age = element.children[1].text
          forth_home_player_gp = element.children[5].text
          forth_home_player_gs = element.children[6].text
          forth_home_player_mp = element.children[7].text
          forth_home_player_fg = element.children[8].text
          forth_home_player_fga = element.children[9].text
          forth_home_player_p = element.children[11].text
          forth_home_player_pa = element.children[12].text
          forth_home_player_ft = element.children[18].text
          forth_home_player_fta = element.children[19].text
          forth_home_player_orb = element.children[21].text
          forth_home_player_stl = element.children[25].text
          forth_home_player_blk = element.children[26].text
          forth_home_player_tov = element.children[27].text
          forth_home_player_pts = element.children[29].text
        end
        if element.children[0].text == '2015-16' && third_flag
          third_flag = false
          third_home_player_age = element.children[1].text
          third_home_player_gp = element.children[5].text
          third_home_player_gs = element.children[6].text
          third_home_player_mp = element.children[7].text
          third_home_player_fg = element.children[8].text
          third_home_player_fga = element.children[9].text
          third_home_player_p = element.children[11].text
          third_home_player_pa = element.children[12].text
          third_home_player_ft = element.children[18].text
          third_home_player_fta = element.children[19].text
          third_home_player_orb = element.children[21].text
          third_home_player_stl = element.children[25].text
          third_home_player_blk = element.children[26].text
          third_home_player_tov = element.children[27].text
          third_home_player_pts = element.children[29].text
        end
        if element.children[0].text == '2016-17' && first_flag
          first_flag = false
          first_home_player_name = home_full_name
          first_home_player_age = element.children[1].text
          first_home_player_gp = element.children[5].text
          first_home_player_gs = element.children[6].text
          first_home_player_mp = element.children[7].text
          first_home_player_fg = element.children[8].text
          first_home_player_fga = element.children[9].text
          first_home_player_p = element.children[11].text
          first_home_player_pa = element.children[12].text
          first_home_player_ft = element.children[18].text
          first_home_player_fta = element.children[19].text
          first_home_player_orb = element.children[21].text
          first_home_player_stl = element.children[25].text
          first_home_player_blk = element.children[26].text
          first_home_player_tov = element.children[27].text
          first_home_player_pts = element.children[29].text
        end
        if element.children[0].text == '2017-18' && second_flag
          second_flag = false
          second_home_player_name = home_full_name
          second_home_player_age = element.children[1].text
          second_home_player_gp = element.children[5].text
          second_home_player_gs = element.children[6].text
          second_home_player_mp = element.children[7].text
          second_home_player_fg = element.children[8].text
          second_home_player_fga = element.children[9].text
          second_home_player_p = element.children[11].text
          second_home_player_pa = element.children[12].text
          second_home_player_ft = element.children[18].text
          second_home_player_fta = element.children[19].text
          second_home_player_orb = element.children[21].text
          second_home_player_stl = element.children[25].text
          second_home_player_blk = element.children[26].text
          second_home_player_tov = element.children[27].text
          second_home_player_pts = element.children[29].text
        end
      end

      url = "https://www.basketball-reference.com#{away_pg_player.player_link}"

      
      doc = download_document(url)
      elements = doc.css('#all_per_game tbody tr')
      first_flag = true
      second_flag = true
      third_flag = true
      forth_flag = true
      elements.each do |element|
        if element.children[0].text == '2014-15' && forth_flag
          forth_flag = false
          forth_away_player_age = element.children[1].text
          forth_away_player_gp = element.children[5].text
          forth_away_player_gs = element.children[6].text
          forth_away_player_mp = element.children[7].text
          forth_away_player_fg = element.children[8].text
          forth_away_player_fga = element.children[9].text
          forth_away_player_p = element.children[11].text
          forth_away_player_pa = element.children[12].text
          forth_away_player_ft = element.children[18].text
          forth_away_player_fta = element.children[19].text
          forth_away_player_orb = element.children[21].text
          forth_away_player_stl = element.children[25].text
          forth_away_player_blk = element.children[26].text
          forth_away_player_tov = element.children[27].text
          forth_away_player_pts = element.children[29].text
        end
        if element.children[0].text == '2015-16' && third_flag
          third_flag = false
          third_away_player_age = element.children[1].text
          third_away_player_gp = element.children[5].text
          third_away_player_gs = element.children[6].text
          third_away_player_mp = element.children[7].text
          third_away_player_fg = element.children[8].text
          third_away_player_fga = element.children[9].text
          third_away_player_p = element.children[11].text
          third_away_player_pa = element.children[12].text
          third_away_player_ft = element.children[18].text
          third_away_player_fta = element.children[19].text
          third_away_player_orb = element.children[21].text
          third_away_player_stl = element.children[25].text
          third_away_player_blk = element.children[26].text
          third_away_player_tov = element.children[27].text
          third_away_player_pts = element.children[29].text
        end
        if element.children[0].text == '2016-17' && first_flag
          first_flag = false
          first_away_player_name = away_full_name
          first_away_player_age = element.children[1].text
          first_away_player_gp = element.children[5].text
          first_away_player_gs = element.children[6].text
          first_away_player_mp = element.children[7].text
          first_away_player_fg = element.children[8].text
          first_away_player_fga = element.children[9].text
          first_away_player_p = element.children[11].text
          first_away_player_pa = element.children[12].text
          first_away_player_ft = element.children[18].text
          first_away_player_fta = element.children[19].text
          first_away_player_orb = element.children[21].text
          first_away_player_stl = element.children[25].text
          first_away_player_blk = element.children[26].text
          first_away_player_tov = element.children[27].text
          first_away_player_pts = element.children[29].text
        end
        if element.children[0].text == '2017-18' && second_flag
          second_flag = false
          second_away_player_name = away_full_name
          second_away_player_age = element.children[1].text
          second_away_player_gp = element.children[5].text
          second_away_player_gs = element.children[6].text
          second_away_player_mp = element.children[7].text
          second_away_player_fg = element.children[8].text
          second_away_player_fga = element.children[9].text
          second_away_player_p = element.children[11].text
          second_away_player_pa = element.children[12].text
          second_away_player_ft = element.children[18].text
          second_away_player_fta = element.children[19].text
          second_away_player_orb = element.children[21].text
          second_away_player_stl = element.children[25].text
          second_away_player_blk = element.children[26].text
          second_away_player_tov = element.children[27].text
          second_away_player_pts = element.children[29].text
        end
      end
      compare.update(head_home_player_name: head_home_player_name, 
        head_away_player_name: head_away_player_name, 
        head_home_player_gp: head_home_player_gp, 
        head_away_player_gp: head_away_player_gp, 
        head_home_player_gs: head_home_player_gs, 
        head_away_player_gs: head_away_player_gs, 
        head_home_player_mp: head_home_player_mp, 
        head_away_player_mp: head_away_player_mp, 
        head_home_player_fg: head_home_player_fg, 
        head_away_player_fg: head_away_player_fg, 
        head_home_player_fga: head_home_player_fga, 
        head_away_player_fga: head_away_player_fga, 
        head_home_player_p: head_home_player_p, 
        head_away_player_p: head_away_player_p, 
        head_home_player_pa: head_home_player_pa, 
        head_away_player_pa: head_away_player_pa, 
        head_home_player_ft: head_home_player_ft, 
        head_away_player_ft: head_away_player_ft, 
        head_home_player_fta: head_home_player_fta, 
        head_away_player_fta: head_away_player_fta, 
        head_home_player_orb: head_home_player_orb, 
        head_away_player_orb: head_away_player_orb, 
        head_home_player_stl: head_home_player_stl, 
        head_away_player_stl: head_away_player_stl, 
        head_home_player_blk: head_home_player_blk, 
        head_away_player_blk: head_away_player_blk, 
        head_home_player_tov: head_home_player_tov, 
        head_away_player_tov: head_away_player_tov, 
        head_home_player_pts: head_home_player_pts, 
        head_away_player_pts: head_away_player_pts, 
        first_home_player_name: first_home_player_name, 
        first_home_player_age: first_home_player_age, 
        first_home_player_gp: first_home_player_gp, 
        first_home_player_gs: first_home_player_gs, 
        first_home_player_mp: first_home_player_mp, 
        first_home_player_fg: first_home_player_fg, 
        first_home_player_fga: first_home_player_fga, 
        first_home_player_p: first_home_player_p, 
        first_home_player_pa: first_home_player_pa, 
        first_home_player_ft: first_home_player_ft, 
        first_home_player_fta: first_home_player_fta, 
        first_home_player_orb: first_home_player_orb, 
        first_home_player_stl: first_home_player_stl, 
        first_home_player_blk: first_home_player_blk, 
        first_home_player_tov: first_home_player_tov, 
        first_home_player_pts: first_home_player_pts, 
        second_home_player_name: second_home_player_name, 
        second_home_player_age: second_home_player_age, 
        second_home_player_gp: second_home_player_gp, 
        second_home_player_gs: second_home_player_gs, 
        second_home_player_mp: second_home_player_mp, 
        second_home_player_fg: second_home_player_fg, 
        second_home_player_fga: second_home_player_fga, 
        second_home_player_p: second_home_player_p, 
        second_home_player_pa: second_home_player_pa, 
        second_home_player_ft: second_home_player_ft, 
        second_home_player_fta: second_home_player_fta, 
        second_home_player_orb: second_home_player_orb, 
        second_home_player_stl: second_home_player_stl, 
        second_home_player_blk: second_home_player_blk, 
        second_home_player_tov: second_home_player_tov, 
        second_home_player_pts: second_home_player_pts, 
        first_away_player_name: first_away_player_name, 
        first_away_player_age: first_away_player_age, 
        first_away_player_gp: first_away_player_gp, 
        first_away_player_gs: first_away_player_gs, 
        first_away_player_mp: first_away_player_mp, 
        first_away_player_fg: first_away_player_fg, 
        first_away_player_fga: first_away_player_fga, 
        first_away_player_p: first_away_player_p, 
        first_away_player_pa: first_away_player_pa, 
        first_away_player_ft: first_away_player_ft, 
        first_away_player_fta: first_away_player_fta, 
        first_away_player_orb: first_away_player_orb, 
        first_away_player_stl: first_away_player_stl, 
        first_away_player_blk: first_away_player_blk, 
        first_away_player_tov: first_away_player_tov, 
        first_away_player_pts: first_away_player_pts, 
        second_away_player_name: second_away_player_name, 
        second_away_player_age: second_away_player_age, 
        second_away_player_gp: second_away_player_gp, 
        second_away_player_gs: second_away_player_gs, 
        second_away_player_mp: second_away_player_mp, 
        second_away_player_fg: second_away_player_fg, 
        second_away_player_fga: second_away_player_fga, 
        second_away_player_p: second_away_player_p, 
        second_away_player_pa: second_away_player_pa, 
        second_away_player_ft: second_away_player_ft, 
        second_away_player_fta: second_away_player_fta, 
        second_away_player_orb: second_away_player_orb, 
        second_away_player_stl: second_away_player_stl, 
        second_away_player_blk: second_away_player_blk, 
        second_away_player_tov: second_away_player_tov, 
        second_away_player_pts: second_away_player_pts,

        forth_away_player_age: forth_away_player_age,
        forth_away_player_gp: forth_away_player_gp,
        forth_away_player_gs: forth_away_player_gs,
        forth_away_player_mp: forth_away_player_mp,
        forth_away_player_fg: forth_away_player_fg,
        forth_away_player_fga: forth_away_player_fga,
        forth_away_player_p: forth_away_player_p,
        forth_away_player_pa: forth_away_player_pa,
        forth_away_player_ft: forth_away_player_ft,
        forth_away_player_fta: forth_away_player_fta,
        forth_away_player_orb: forth_away_player_orb,
        forth_away_player_stl: forth_away_player_stl,
        forth_away_player_blk: forth_away_player_blk,
        forth_away_player_tov: forth_away_player_tov,
        forth_away_player_pts: forth_away_player_pts,
        third_away_player_age: third_away_player_age,
        third_away_player_gp: third_away_player_gp,
        third_away_player_gs: third_away_player_gs,
        third_away_player_mp: third_away_player_mp,
        third_away_player_fg: third_away_player_fg,
        third_away_player_fga: third_away_player_fga,
        third_away_player_p: third_away_player_p,
        third_away_player_pa: third_away_player_pa,
        third_away_player_ft: third_away_player_ft,
        third_away_player_fta: third_away_player_fta,
        third_away_player_orb: third_away_player_orb,
        third_away_player_stl: third_away_player_stl,
        third_away_player_blk: third_away_player_blk,
        third_away_player_tov: third_away_player_tov,
        third_away_player_pts: third_away_player_pts,

        forth_home_player_age: forth_home_player_age,
        forth_home_player_gp: forth_home_player_gp,
        forth_home_player_gs: forth_home_player_gs,
        forth_home_player_mp: forth_home_player_mp,
        forth_home_player_fg: forth_home_player_fg,
        forth_home_player_fga: forth_home_player_fga,
        forth_home_player_p: forth_home_player_p,
        forth_home_player_pa: forth_home_player_pa,
        forth_home_player_ft: forth_home_player_ft,
        forth_home_player_fta: forth_home_player_fta,
        forth_home_player_orb: forth_home_player_orb,
        forth_home_player_stl: forth_home_player_stl,
        forth_home_player_blk: forth_home_player_blk,
        forth_home_player_tov: forth_home_player_tov,
        forth_home_player_pts: forth_home_player_pts,
        third_home_player_age: third_home_player_age,
        third_home_player_gp: third_home_player_gp,
        third_home_player_gs: third_home_player_gs,
        third_home_player_mp: third_home_player_mp,
        third_home_player_fg: third_home_player_fg,
        third_home_player_fga: third_home_player_fga,
        third_home_player_p: third_home_player_p,
        third_home_player_pa: third_home_player_pa,
        third_home_player_ft: third_home_player_ft,
        third_home_player_fta: third_home_player_fta,
        third_home_player_orb: third_home_player_orb,
        third_home_player_stl: third_home_player_stl,
        third_home_player_blk: third_home_player_blk,
        third_home_player_tov: third_home_player_tov,
        third_home_player_pts: third_home_player_pts
        )
    end
  end

  # one time for referee table
  task :getRefereeStatic => :environment do
    @referee_filter_third = []
    (0..7).each do |one_element|
      @referee_filter_second = []
      (0..7).each do |two_element|
        @referee_filter_first = []
        (0..7).each do |three_element|
          search_array_last = []
          search_array_next = []
          if one_element > 6
            search_array_last.push("referee_one_last > 8")
            search_array_next.push("referee_one_next > 8")
          elsif one_element > 5
            search_array_last.push("referee_one_last < 9 AND referee_one_last > 5")
            search_array_next.push("referee_one_next < 9 AND referee_one_next > 5")
          else
            search_array_last.push("referee_one_last = #{one_element}")
            search_array_next.push("referee_one_next = #{one_element}")
          end
          if two_element > 6
            search_array_last.push("referee_two_last > 8")
            search_array_next.push("referee_two_next > 8")
          elsif two_element > 5
            search_array_last.push("referee_two_last < 9 AND referee_two_last > 5")
            search_array_next.push("referee_two_next < 9 AND referee_two_next > 5")
          else
            search_array_last.push("referee_two_last = #{two_element}")
            search_array_next.push("referee_two_next = #{two_element}")
          end
          if three_element > 6
            search_array_last.push("referee_three_last > 8")
            search_array_next.push("referee_three_next > 8")
          elsif three_element > 5
            search_array_last.push("referee_three_last < 9 AND referee_three_last > 5")
            search_array_next.push("referee_three_next < 9 AND referee_three_next > 5")
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
    (0..7).each do |one_element|
      (one_element..7).each do |two_element|
        start_element = two_element
        start_element = 0 if one_element == 0
        (start_element..7).each do |three_element|
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

          if one_element > 6
            referee_one_last = "9+"
          elsif one_element > 5
            referee_one_last = "6-8"
          else
            referee_one_last = one_element.to_s
          end

          if two_element > 6
            referee_two_last = "9+"
          elsif two_element > 5
            referee_two_last = "6-8"
          else
            referee_two_last = two_element.to_s
          end

          if three_element > 6
            referee_three_last = "9+"
          elsif three_element > 5
            referee_three_last = "6-8"
          else
            referee_three_last = three_element.to_s
          end
          
          Refereestatic.create(
            referee_one: referee_one_last,
            referee_two: referee_two_last,
            referee_three: referee_three_last,
            last_count: total_last_count,
            last_first: total_last_first.round(2),
            last_second: total_last_second.round(2),
            next_count: total_next_count,
            next_first: total_next_first.round(2),
            next_second: total_next_second.round(2)
          )
        end
      end
    end
  end

  task :fixingscores => :environment do
    include Api
    games = Nba.where("game_date between ? and ?", (Date.today - 5.days).beginning_of_day, Time.now-5.hours)
    puts games.size
    games.each do |game|
      date = DateTime.parse(game.game_date).in_time_zone
      abbr = game.home_abbr
      url = "https://www.basketball-reference.com/boxscores/#{date.strftime('%Y%m%d')}0#{abbr}.html"
      puts url
      doc = download_document(url)
      unless doc
        if abbr == 'BKN'
          abbr = 'BRK'
        elsif abbr == 'CHA'
          abbr = 'CHO'
        elsif abbr == 'PHX'
          abbr = 'PHO'
        elsif abbr == 'GS'
          abbr = 'GSW'
        elsif abbr == 'NO'
          abbr = 'NOH'
        elsif abbr == 'NY'
          abbr = 'NYK'
        elsif abbr == 'WSH'
          abbr = 'WAS'
        elsif abbr == 'SA'
          abbr = 'SAS'
        elsif abbr == 'OKC'
          abbr = 'SEA'
        elsif abbr == 'NJ'
          abbr = 'NJN'
        elsif abbr == 'UTAH'
          abbr = 'UTA'
        end
        url = "https://www.basketball-reference.com/boxscores/#{date.strftime('%Y%m%d')}0#{abbr}.html"
        doc = download_document(url)
      end
      unless doc
        if abbr == 'BRK'
          abbr = 'NJN'
        elsif abbr == 'NOH'
          abbr = 'NOP'
        elsif abbr == 'CHO'
          abbr = 'CHH'
        end
        url = "https://www.basketball-reference.com/boxscores/#{date.strftime('%Y%m%d')}0#{abbr}.html"
        doc = download_document(url)
      end
      unless doc
        if abbr == 'NOP'
          abbr = 'NOK'
        end
        url = "https://www.basketball-reference.com/boxscores/#{date.strftime('%Y%m%d')}0#{abbr}.html"
        doc = download_document(url)
      end
      unless doc
        next
      end
      doc.xpath('//comment()').each { |comment| comment.replace(comment.text) }
      elements = doc.css(".suppress_all tr")
      away_first_quarter  = elements[2].children[3].text.to_i
      away_second_quarter = elements[2].children[5].text.to_i
      away_third_quarter  = elements[2].children[7].text.to_i
      away_forth_quarter  = elements[2].children[9].text.to_i
      away_ot_quarter   = game.away_ot_quarter.to_i

      home_first_quarter  = elements[3].children[3].text.to_i
      home_second_quarter = elements[3].children[5].text.to_i
      home_third_quarter  = elements[3].children[7].text.to_i
      home_forth_quarter  = elements[3].children[9].text.to_i
      home_ot_quarter   = game.home_ot_quarter.to_i

      away_score = away_first_quarter + away_second_quarter + away_third_quarter + away_forth_quarter + away_ot_quarter
      home_score = home_first_quarter + home_second_quarter + home_third_quarter + home_forth_quarter + home_ot_quarter

      pace = elements[6].children[1].text.to_f
      away_ortg = elements[6].children[6].text.to_f
      home_ortg = elements[7].children[6].text.to_f

      game.update(away_first_quarter: away_first_quarter, home_first_quarter: home_first_quarter, away_second_quarter: away_second_quarter, home_second_quarter: home_second_quarter, away_third_quarter: away_third_quarter, home_third_quarter: home_third_quarter, away_forth_quarter: away_forth_quarter, home_forth_quarter: home_forth_quarter, away_ot_quarter: away_ot_quarter, home_ot_quarter: home_ot_quarter, away_score: away_score, home_score: home_score, total_score: home_score + away_score, first_point: home_first_quarter + home_second_quarter + away_first_quarter + away_second_quarter, second_point: home_forth_quarter + away_forth_quarter + away_third_quarter + home_third_quarter, total_point: away_first_quarter + away_second_quarter + away_third_quarter + away_forth_quarter + home_first_quarter + home_second_quarter + home_third_quarter + home_forth_quarter, pace: pace, away_ortg: away_ortg, home_ortg: home_ortg)
    end
  end

  task :teaminfo => :environment do
    include Api
    url = "http://www.espn.com/nba/standings/_/sort/wins/dir/desc/group/league"
    doc = download_document(url)
    elements = doc.css("abbr")
    puts elements.length
    elements.each_with_index do |element, index|
      unless team = Team.find_by(abbr: element.text)
        team = Team.create(abbr: element.text)
      end
      team.update(order_one_seventeen: index + 1)
    end

    url = "http://www.espn.com/nba/standings/_/sort/avgpointsfor/dir/desc/group/league"
    doc = download_document(url)
    elements = doc.css("abbr")
    puts elements.length
    elements.each_with_index do |element, index|
      unless team = Team.find_by(abbr: element.text)
        team = Team.create(abbr: element.text)
      end
      team.update(order_two_seventeen: index + 1)
    end

    url = "http://www.espn.com/nba/standings/_/sort/avgpointsagainst/dir/desc/group/league"
    doc = download_document(url)
    elements = doc.css("abbr")
    puts elements.length
    elements.each_with_index do |element, index|
      unless team = Team.find_by(abbr: element.text)
        team = Team.create(abbr: element.text)
      end
      team.update(order_thr_seventeen: index + 1)
    end
  end

  task :getpg => :environment do
    include Api
    Time.zone = 'Eastern Time (US & Canada)'

    games = Nba.where("pg_away_one_name is null")
    games = Nba.where("game_date between ? and ?", (Date.today - 3.days).beginning_of_day, Date.today.end_of_day)
    puts games.size
    games.each do |game|
      players = game.players.where("team_abbr = 0 AND position = 'PG'").order(mins: :desc)
      pg_away_one_name = ""
      pg_away_one_min = 0
      pg_away_two_name = ""
      pg_away_two_min = 0
      pg_away_three_name = ""
      pg_away_three_min = 0
      away_fg_percent = ""
      home_fg_percent = ""
      if players[0]
        pg_away_one_name = players[0].player_name
        pg_away_one_min = players[0].mins
      else
        pg_away_one_name = nil
        pg_away_one_min = nil
      end

      if players[1]
        pg_away_two_name = players[1].player_name
        pg_away_two_min = players[1].mins
      else
        pg_away_two_name = nil
        pg_away_two_min = nil
      end

      if players[2]
        pg_away_three_name = players[2].player_name
        pg_away_three_min = players[2].mins
      else
        pg_away_three_name = nil
        pg_away_three_min = nil
      end

      players = game.players.where("team_abbr = 1 AND position = 'PG'").order(mins: :desc)
      pg_home_one_name = ""
      pg_home_one_min = 0
      pg_home_two_name = ""
      pg_home_two_min = 0
      pg_home_three_name = ""
      pg_home_three_min = 0
      if players[0]
        pg_home_one_name = players[0].player_name
        pg_home_one_min = players[0].mins
      else
        pg_home_one_name = nil
        pg_home_one_min = nil
      end

      if players[1]
        pg_home_two_name = players[1].player_name
        pg_home_two_min = players[1].mins
      else
        pg_home_two_name = nil
        pg_home_two_min = nil
      end

      if players[2]
        pg_home_three_name = players[2].player_name
        pg_home_three_min = players[2].mins
      else
        pg_home_three_name = nil
        pg_home_three_min = nil
      end
      game_id = game.game_id

      url = "http://www.espn.com/nba/boxscore?gameId=#{game_id}"
      doc = download_document(url)
      puts url
      element = doc.css(".highlight")
      if element.size > 3
        away_value = element[1]
        home_value = element[3]

        away_fg_percent = away_value.children[2].text
        home_fg_percent = home_value.children[2].text
        if away_fg_percent == "-----"
          home_fg_percent = "-----"
        end
     end

      game.update(
        pg_away_one_name: pg_away_one_name,
        pg_away_one_min: pg_away_one_min,
        pg_away_two_name: pg_away_two_name,
        pg_away_two_min: pg_away_two_min,
        pg_away_three_name: pg_away_three_name,
        pg_away_three_min: pg_away_three_min,
        pg_home_one_name: pg_home_one_name,
        pg_home_one_min: pg_home_one_min,
        pg_home_two_name: pg_home_two_name,
        pg_home_two_min: pg_home_two_min,
        pg_home_three_name: pg_home_three_name,
        pg_home_three_min: pg_home_three_min,
        away_fg_percent: away_fg_percent,
        home_fg_percent: home_fg_percent
      )
    end
  end

  task :addAVGs => :environment do
    include Api
    Time.zone = 'Eastern Time (US & Canada)'

    games = Nba.where("avg_fg_road is null")
    games = Nba.where("game_date between ? and ?", (Date.today - 3.days).beginning_of_day, Date.today.end_of_day)
    puts games.size
    games.each do |game|
      countItem = Fullseason.where("awaylastfly = ? AND awaynextfly = ? AND roadlast = ? AND roadnext = ? AND homenext = ? AND homelast = ? AND homenextfly = ? AND homelastfly = ?", game.away_last_fly, game.away_next_fly, game.away_last_game, game.away_next_game, game.home_next_game, game.home_last_game, game.home_next_fly, game.home_last_fly)
      avg_fg_road = (countItem.average(:roadfirsthalf).to_f + countItem.average(:roadthird).to_f + countItem.average(:roadforth).to_f).round(2)
      avg_fg_home = (countItem.average(:homefirsthalf).to_f + countItem.average(:homethird).to_f + countItem.average(:homeforth).to_f).round(2)
      avg_fg_total = countItem.average(:totalvalue).to_f.round(2)
      avg_first_road = countItem.average(:roadfirsthalf).to_f.round(2)
      avg_first_home = countItem.average(:homefirsthalf).to_f.round(2)
      avg_first_total = countItem.average(:firstvalue).to_f.round(2)
      avg_second_road = (countItem.average(:roadthird).to_f + countItem.average(:roadforth).to_f).round(2)
      avg_second_home = (countItem.average(:homethird).to_f + countItem.average(:homeforth).to_f).round(2)
      avg_second_total = countItem.average(:secondvalue).to_f.round(2)
      avg_count = countItem.count(:totalvalue).to_i

      game.update(
        avg_fg_road: avg_fg_road,
        avg_fg_home: avg_fg_home,
        avg_fg_total: avg_fg_total,
        avg_first_road: avg_first_road,
        avg_first_home: avg_first_home,
        avg_first_total: avg_first_total,
        avg_second_road: avg_second_road,
        avg_second_home: avg_second_home,
        avg_second_total: avg_second_total,
        avg_count: avg_count
      )
    end
  end

  task :getReferee => :environment do
    include Api
    games = Nba.where("game_date between ? and ?", (Date.today - 3.days).beginning_of_day, Date.today.end_of_day)
    puts games.size
    games.each do |game|
      game_id = game.game_id

      url = "http://www.espn.com/nba/game?gameId=#{game_id}"
      doc = download_document(url)
      puts url
      element = doc.css(".game-info-note__content")
      if element.size > 0
        referees = element[0].text.split(', ')
        game_date = game.game_date

        referee_one_last_days = ""
        referee_one_last = Nba.where("referee_one = ? AND game_date < ?", referees[0], game_date).or(Nba.where("referee_two = ? AND game_date < ?", referees[0], game_date).or(Nba.where("referee_three = ? AND game_date < ?", referees[0], game_date))).order(:game_date).last
        if referee_one_last
          referee_one_last_days = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(referee_one_last.game_date).in_time_zone.to_date ).to_i - 1
          if referee_one_last.referee_one == referees[0]
            referee_one_last.update(referee_one_next: referee_one_last_days)
          elsif referee_one_last.referee_two == referees[0]
            referee_one_last.update(referee_two_next: referee_one_last_days)
          else
            referee_one_last.update(referee_three_next: referee_one_last_days)
          end
        end

        referee_two_last_days = ""
        referee_two_last = Nba.where("referee_one = ? AND game_date < ?", referees[1], game_date).or(Nba.where("referee_two = ? AND game_date < ?", referees[1], game_date).or(Nba.where("referee_three = ? AND game_date < ?", referees[1], game_date))).order(:game_date).last
        if referee_two_last
          referee_two_last_days = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(referee_two_last.game_date).in_time_zone.to_date ).to_i - 1
          if referee_two_last.referee_one == referees[1]
            referee_two_last.update(referee_one_next: referee_two_last_days)
          elsif referee_two_last.referee_two == referees[1]
            referee_two_last.update(referee_two_next: referee_two_last_days)
          else
            referee_two_last.update(referee_three_next: referee_two_last_days)
          end
        end

        referee_three_last_days = ""
        referee_three_last = Nba.where("referee_one = ? AND game_date < ?", referees[2], game_date).or(Nba.where("referee_two = ? AND game_date < ?", referees[2], game_date).or(Nba.where("referee_three = ? AND game_date < ?", referees[2], game_date))).order(:game_date).last
        if referee_three_last
          referee_three_last_days = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(referee_three_last.game_date).in_time_zone.to_date ).to_i - 1
          if referee_three_last.referee_one == referees[2]
            referee_three_last.update(referee_one_next: referee_three_last_days)
          elsif referee_three_last.referee_two == referees[2]
            referee_three_last.update(referee_two_next: referee_three_last_days)
          else
            referee_three_last.update(referee_three_next: referee_three_last_days)
          end
        end
        
        game.update(
          referee_one: referees[0],
          referee_one_last: referee_one_last_days,
          referee_two: referees[1],
          referee_two_last: referee_two_last_days,
          referee_three: referees[2],
          referee_three_last: referee_three_last_days
        )

      end
    end
  end

  task :getTodayReferee => [:environment] do
    include Api
    games = Nba.where("game_date between ? and ?", Date.today.beginning_of_day, Date.today.end_of_day)

    url = "http://official.nba.com/referee-assignments/"
    doc = download_document(url)
    elements = doc.css(".nba-refs-content tbody tr")
    elements.each do |element|
      team = element.children[1].text.split(" @ ")
      away_name = team[0]
      home_name = team[1]
      if @nba_nicknames[away_name]
        away_name = @nba_nicknames[away_name]
      end

      if @nba_nicknames[home_name]
        home_name = @nba_nicknames[home_name]
      end
      puts away_name
      puts home_name
      matched = games.select{|field| ((field.home_team.include?(home_name) && field.away_team.include?(away_name)) || (field.home_team.include?(away_name) && field.away_team.include?(home_name))) }
      if matched.size > 0
        update_game = matched.first
        referee_one = element.children[3].children[1].children[0].text.split(' (#')[0].squish
        referee_two = element.children[5].children[1].children[0].text.split(' (#')[0].squish
        referee_three = element.children[7].children[1].children[0].text.split(' (#')[0].squish

        if @player_nicknames[referee_one]
          referee_one = @player_nicknames[referee_one]
        end

        if @player_nicknames[referee_two]
          referee_two = @player_nicknames[referee_two]
        end

        if @player_nicknames[referee_three]
          referee_three = @player_nicknames[referee_three]
        end

        game_date = update_game.game_date

        referee_one_last_days = ""
        referee_one_last = Nba.where("referee_one = ? AND game_date < ?", referee_one, game_date).or(Nba.where("referee_two = ? AND game_date < ?", referee_one, game_date).or(Nba.where("referee_three = ? AND game_date < ?", referee_one, game_date))).order(:game_date).last
        if referee_one_last
          referee_one_last_days = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(referee_one_last.game_date).in_time_zone.to_date ).to_i - 1
          if referee_one_last.referee_one == referee_one
            referee_one_last.update(referee_one_next: referee_one_last_days)
          elsif referee_one_last.referee_two == referee_one
            referee_one_last.update(referee_two_next: referee_one_last_days)
          else
            referee_one_last.update(referee_three_next: referee_one_last_days)
          end
        end

        referee_two_last_days = ""
        referee_two_last = Nba.where("referee_one = ? AND game_date < ?", referee_two, game_date).or(Nba.where("referee_two = ? AND game_date < ?", referee_two, game_date).or(Nba.where("referee_three = ? AND game_date < ?", referee_two, game_date))).order(:game_date).last
        if referee_two_last
          referee_two_last_days = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(referee_two_last.game_date).in_time_zone.to_date ).to_i - 1
          if referee_two_last.referee_one == referee_two
            referee_two_last.update(referee_one_next: referee_two_last_days)
          elsif referee_two_last.referee_two == referee_two
            referee_two_last.update(referee_two_next: referee_two_last_days)
          else
            referee_two_last.update(referee_three_next: referee_two_last_days)
          end
        end

        referee_three_last_days = ""
        referee_three_last = Nba.where("referee_one = ? AND game_date < ?", referee_three, game_date).or(Nba.where("referee_two = ? AND game_date < ?", referee_three, game_date).or(Nba.where("referee_three = ? AND game_date < ?", referee_three, game_date))).order(:game_date).last
        if referee_three_last
          referee_three_last_days = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(referee_three_last.game_date).in_time_zone.to_date ).to_i - 1
          if referee_three_last.referee_one == referee_three
            referee_three_last.update(referee_one_next: referee_three_last_days)
          elsif referee_three_last.referee_two == referee_three
            referee_three_last.update(referee_two_next: referee_three_last_days)
          else
            referee_three_last.update(referee_three_next: referee_three_last_days)
          end
        end

        update_game.update(
          referee_one: referee_one,
          referee_one_last: referee_one_last_days,
          referee_two: referee_two,
          referee_two_last: referee_two_last_days,
          referee_three: referee_three,
          referee_three_last: referee_three_last_days
        )
      end
    end
  end

  task :getStarter => [:environment] do
    include Api
    Time.zone = 'Eastern Time (US & Canada)'
    url = "https://www.rotowire.com/basketball/nba-lineups.php"
    0.upto(1) do |type|
      doc = download_document(url)
      times = doc.css(".lineup__time")[0..-2]
      away_teams = doc.css(".is-visit .lineup__abbr")
      home_teams = doc.css(".is-home .lineup__abbr")
      players = doc.css(".lineup__list")
      times.each_with_index do |time_element, index|
        time = DateTime.parse(time_element.children[0].text)
        time = time + type.days
        away_team = away_teams[index].text.squish
        home_team = home_teams[index].text.squish
        away_players = players[index*2]
        home_players = players[index*2 + 1]
        away_players.children.each_with_index do |away_player, index|
          next if index % 2 == 0 || index > 12 || index < 2
          next if away_player.children.size < 3
          position = away_player.children[1].text.squish
          player_name = away_player.children[3].children[0].text.squish
          starter = Starter.find_or_create_by(time: time.to_s, team: away_team, index: (index - 1)/2)
          starter.update(position: position, player_name: player_name)
        end
        home_players.children.each_with_index do |home_player, index|
          next if index % 2 == 0 || index > 12 || index < 2
          next if home_player.children.size < 3
          position = home_player.children[1].text.squish
          player_name = home_player.children[3].children[0].text.squish
          starter = Starter.find_or_create_by(time: time.to_s, team: home_team, index: (index - 1)/2)
          starter.update(position: position, player_name: player_name)
        end
      end
      url = "https://www.rotowire.com/basketball/nba-lineups.php?date=tomorrow"
    end
  end

  # NBA CLONE
  task :movegame => [:environment] do
    include Api
    Time.zone = 'Eastern Time (US & Canada)'
    games = Nba.where("game_date < ?", Date.new(2006, 10, 30).beginning_of_day)
    games.each do |game|
      unless clonegame = NbaClone.find_by(game_id: game.game_id)
        clonegame = NbaClone.create(game.attributes)
      end
      clonegame.update(first_opener_side: nil,
        first_closer_side: nil,
        first_opener_total: nil,
        first_closer_total: nil,
        second_opener_side: nil,
        second_closer_side: nil,
        second_opener_total: nil,
        second_closer_total: nil,
        full_opener_side: nil,
        full_closer_side: nil,
        full_opener_total: nil,
        full_closer_total: nil
      )
    end
  end

  task :getDateClone => [:environment] do
    puts "----------Get Games----------"
    include Api
    Time.zone = 'Eastern Time (US & Canada)'
    index_date = Date.new(1993,11,5)
    while index_date <= Date.new(1994,4,24)
      game_date = index_date.strftime("%Y%m%d")
      
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
        
        unless game = NbaClone.find_by(game_id: game_id)
          game = NbaClone.create(game_id: game_id)
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
        if element.size > 3
          away_value = element[0]
          home_value = element[2]

          away_mins_value = away_value.children[1].text.to_i
          away_fga_value = away_value.children[2].text
          away_fga_index = away_fga_value.index('-')
          away_fga_value = away_fga_index ? away_fga_value[away_fga_index+1..-1].to_i : 0
          away_to_value = away_value.children[11].text.to_i
          away_pf_value = away_value.children[12].text.to_i
          away_fta_value = away_value.children[4].text
          away_fta_index = away_fta_value.index('-')
          away_fta_value = away_fta_index ? away_fta_value[away_fta_index+1..-1].to_i : 0
          away_or_value = away_value.children[5].text.to_i
          away_stl_value = away_value.children[9].text.to_i
          away_blk_value = away_value.children[10].text.to_i

          home_mins_value = home_value.children[1].text.to_i
          home_fga_value = home_value.children[2].text
          home_fga_index = home_fga_value.index('-')
          home_fga_value = home_fga_index ? home_fga_value[home_fga_index+1..-1].to_i : 0
          home_to_value = home_value.children[11].text.to_i
          home_pf_value = home_value.children[12].text.to_i
          home_fta_value = home_value.children[4].text
          home_fta_index = home_fta_value.index('-')
          home_fta_value = home_fta_index ? home_fta_value[home_fta_index+1..-1].to_i : 0
          home_or_value = home_value.children[5].text.to_i
          home_stl_value = home_value.children[9].text.to_i
          home_blk_value = home_value.children[10].text.to_i
         end

        addingDate = date
        home_timezone = ''
        home_win_rank = 0
        home_ppg_rank = 0
        home_oppppg_rank = 0

        away_timezone = ''
        away_win_rank = 0
        away_ppg_rank = 0
        away_oppppg_rank = 0

        if @team_names[home_team]
          compare_home_team = @team_names[home_team]
          home_team_info = Team.find_by(team: compare_home_team)
          if home_team_info.timezone == 2
            addingDate = addingDate - 3.hours
            home_timezone = "PACIFIC"
          elsif home_team_info.timezone == 3
            addingDate = addingDate - 1.hours
            home_timezone = "CENTRAL"
          elsif home_team_info.timezone == 4
            addingDate = addingDate - 2.hours
            home_timezone = "MOUNTAIN"
          elsif home_team_info.timezone == 1
            home_timezone = "EASTERN"
          end
          home_win_rank = home_team_info.order_one_seventeen
          home_ppg_rank = home_team_info.order_two_seventeen
          home_oppppg_rank = home_team_info.order_thr_seventeen
        end

        if @team_names[away_team]
          compare_away_team = @team_names[away_team]
          away_team_info = Team.find_by(team: compare_away_team)
          if away_team_info.timezone == 2
            away_timezone = "PACIFIC"
          elsif away_team_info.timezone == 3
            away_timezone = "CENTRAL"
          elsif away_team_info.timezone == 4
            away_timezone = "MOUNTAIN"
          elsif away_team_info.timezone == 1
            away_timezone = "EASTERN"
          end
          away_win_rank = away_team_info.order_one_seventeen
          away_ppg_rank = away_team_info.order_two_seventeen
          away_oppppg_rank = away_team_info.order_thr_seventeen
        end
        game.update(away_team: away_team, home_team: home_team, home_abbr: home_abbr, away_abbr: away_abbr, game_date: date, year: addingDate.strftime("%Y"), date: addingDate.strftime("%b %e"), time: addingDate.strftime("%I:%M%p"), week: addingDate.strftime("%a"), away_mins: away_mins_value, away_fga: away_fga_value, away_fta: away_fta_value, away_toValue: away_to_value, away_orValue: away_or_value, home_mins: home_mins_value, home_fga: home_fga_value, home_fta: home_fta_value, home_toValue: home_to_value, home_orValue: home_or_value, home_timezone: home_timezone, home_win_rank: home_win_rank, home_ppg_rank: home_ppg_rank, home_oppppg_rank: home_oppppg_rank, away_timezone: away_timezone, away_win_rank: away_win_rank, away_ppg_rank: away_ppg_rank, away_oppppg_rank: away_oppppg_rank, away_stl: away_stl_value, away_blk: away_blk_value, home_stl: home_stl_value, home_blk: home_blk_value, away_pf: away_pf_value, home_pf: home_pf_value)
      end
      index_date = index_date + 1.days
    end
  end

  task :getScoreClone => [:environment] do
    include Api
    puts "----------Get Score----------"

    games = NbaClone.where("away_first_quarter is null")
    puts games.size
    games.each do |game|
      game_id = game.game_id

      url = "http://www.espn.com/nba/playbyplay?gameId=#{game_id}"
        doc = download_document(url)
      puts url
      elements = doc.css("#linescore tbody tr")
      if elements.size > 1
        if elements[0].children.size > 5
          away_first_quarter  = elements[0].children[1].text.to_i
          away_second_quarter = elements[0].children[2].text.to_i
          away_third_quarter  = elements[0].children[3].text.to_i
          away_forth_quarter  = elements[0].children[4].text.to_i
          away_ot_quarter   = 0

          home_first_quarter  = elements[1].children[1].text.to_i
          home_second_quarter = elements[1].children[2].text.to_i
          home_third_quarter  = elements[1].children[3].text.to_i
          home_forth_quarter  = elements[1].children[4].text.to_i
          home_ot_quarter   = 0

          if elements[0].children.size > 6
            away_ot_quarter = elements[0].children[5].text.to_i
              home_ot_quarter = elements[1].children[5].text.to_i
          end
        end
      else
        away_first_quarter  = 0
        away_second_quarter = 0
        away_third_quarter  = 0
        away_forth_quarter  = 0
        away_ot_quarter   = 0

        home_first_quarter  = 0
        home_second_quarter = 0
        home_third_quarter  = 0
        home_forth_quarter  = 0
        home_ot_quarter   = 0
      end
      away_score = away_first_quarter + away_second_quarter + away_third_quarter + away_forth_quarter + away_ot_quarter
      home_score = home_first_quarter + home_second_quarter + home_third_quarter + home_forth_quarter + home_ot_quarter

      game.update(away_first_quarter: away_first_quarter, home_first_quarter: home_first_quarter, away_second_quarter: away_second_quarter, home_second_quarter: home_second_quarter, away_third_quarter: away_third_quarter, home_third_quarter: home_third_quarter, away_forth_quarter: away_forth_quarter, home_forth_quarter: home_forth_quarter, away_ot_quarter: away_ot_quarter, home_ot_quarter: home_ot_quarter, away_score: away_score, home_score: home_score, total_score: home_score + away_score, first_point: home_first_quarter + home_second_quarter + away_first_quarter + away_second_quarter, second_point: home_forth_quarter + away_forth_quarter + away_third_quarter + home_third_quarter, total_point: away_first_quarter + away_second_quarter + away_third_quarter + away_forth_quarter + home_first_quarter + home_second_quarter + home_third_quarter + home_forth_quarter)
    end
  end

  task :getLinkGameClone => [:environment] do
    include Api
    puts "----------Get Link Games----------"

    Time.zone = 'Eastern Time (US & Canada)'

    games = NbaClone.where("game_date between ? and ?", (Date.new(2000, 4, 17) - 10.days).beginning_of_day, (Date.new(2000, 4, 17) + 10.days).beginning_of_day)
    puts games.size
    games.each do |game|
      home_team = game.home_team
      away_team = game.away_team
      game_date = game.game_date

      away_last_game = ""
      away_last_fly = ""
      away_last_ot = ""
      away_team_prev = NbaClone.where("home_team = ? AND game_date < ?", away_team, game_date).or(NbaClone.where("away_team = ? AND game_date < ?", away_team, game_date)).order(:game_date).last
      if away_team_prev
        away_last_game = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(away_team_prev.game_date).in_time_zone.to_date ).to_i - 1
        if away_team_prev.home_team == away_team
          away_last_fly = "YES"
        else
          away_last_fly = "NO"
        end
        if away_team_prev.away_ot_quarter != nil &&  away_team_prev.home_ot_quarter != nil
          if away_team_prev.away_ot_quarter > 0 || away_team_prev.home_ot_quarter > 0
            away_last_ot = "YES"
          else
            away_last_ot = "NO"
          end
        end
      end

      away_next_game = ""
      away_next_fly = ""
      away_team_next = NbaClone.where("home_team = ? AND game_date > ?", away_team, game_date).or(NbaClone.where("away_team = ? AND game_date > ?", away_team, game_date)).order(:game_date).first
      if away_team_next
        away_next_game = (DateTime.parse(away_team_next.game_date).in_time_zone.to_date  - DateTime.parse(game_date).in_time_zone.to_date ).to_i - 1
        if away_team_next.home_team == away_team
          away_next_fly = "YES"
        else
          away_next_fly = "NO"
        end
      end

      home_last_game = ""
      home_last_fly = ""
      home_last_ot = ""
      home_team_prev = NbaClone.where("home_team = ? AND game_date < ?", home_team, game_date).or(NbaClone.where("away_team = ? AND game_date < ?", home_team, game_date)).order(:game_date).last
      if home_team_prev
        home_last_game = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(home_team_prev.game_date).in_time_zone.to_date ).to_i - 1
        if home_team_prev.home_team == home_team
          home_last_fly = "NO"
        else
          home_last_fly = "YES"
        end
        if home_team_prev.away_ot_quarter != nil && home_team_prev.home_ot_quarter != nil
          if home_team_prev.away_ot_quarter > 0 || home_team_prev.home_ot_quarter > 0
            home_last_ot = "YES"
          else
            home_last_ot = "NO"
          end
        end
      end

      home_next_game = ""
      home_next_fly = ""
      home_team_next = NbaClone.where("home_team = ? AND game_date > ?", home_team, game_date).or(NbaClone.where("away_team = ? AND game_date > ?", home_team, game_date)).order(:game_date).first
      if home_team_next
        home_next_game = (DateTime.parse(home_team_next.game_date).in_time_zone.to_date  - DateTime.parse(game_date).in_time_zone.to_date ).to_i - 1
        if home_team_next.home_team == home_team
          home_next_fly = "NO"
        else
          home_next_fly = "YES"
        end
      end

      away_last_home = ""
      away_team_prev = NbaClone.where("home_team = ? AND game_date < ?", away_team, game_date).order(:game_date).last
      if away_team_prev
        away_last_home = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(away_team_prev.game_date).in_time_zone.to_date ).to_i - 1
      end

      away_next_home = ""
      away_team_next = NbaClone.where("home_team = ? AND game_date > ?", away_team, game_date).order(:game_date).first
      if away_team_next
        away_next_home = (DateTime.parse(away_team_next.game_date).in_time_zone.to_date  - DateTime.parse(game_date).in_time_zone.to_date ).to_i - 1
      end

      game.update(away_last_game: away_last_game, away_next_game: away_next_game, home_last_game: home_last_game, home_next_game: home_next_game, home_next_fly: home_next_fly, home_last_fly: home_last_fly, away_next_fly: away_next_fly, away_last_fly: away_last_fly, home_last_ot: home_last_ot, away_last_ot: away_last_ot, away_last_home: away_last_home,away_next_home: away_next_home )
    end
  end

  task :getGames => [:environment] do
    include Api
    url = "https://www.covers.com/pageLoader/pageLoader.aspx?page=/data/nba/teams/teams.html"
    doc = download_document(url)
    puts url
    elements = doc.css("table a")
    elements.each do |element|
      team_url = element['href']
      team_index = team_url.rindex("/")
      (1990..2005).each do |year|
        year_team_url = 'https://www.covers.com' + team_url[0..team_index] + "pastresults/#{year}-#{year+1}/" + team_url[team_index+1..-1]
        puts year_team_url
        doc = download_document(year_team_url)
        datas = doc.css("table").last
        next unless datas
        datas = datas.children
        datas.each_with_index do |data, index|
          if index > 2 && index % 2 == 1
            home_team_url = element['href']
            home_team_index = home_team_url.rindex("/")
            home_team = home_team_url[home_team_index+1..-1]
            home_team = @home_team[home_team] if @home_team[home_team]

            data_date = Date.strptime(data.children[1].text.squish, '%m/%d/%y')
            away_type = 0
            away_team = data.children[3].text.squish
            away_type = 1 if away_team[0] == '@'
            away_team = away_team[2..-1] if away_team[0] == '@'

            score = data.children[5].text.squish
            score_rindex = score.rindex(' (OT)')
            score = score_rindex ? score[0..score_rindex-1] : score
            score_index = score.index(' ')
            score = score[score_index..-1]
            score_index = score.index('-')
            home_score = score[1..score_index-1]
            away_score = score[score_index+1..-1]

            full_closer_side = data.children[9].text.squish
            full_closer_side_index = full_closer_side.index(' ')
            full_closer_side = full_closer_side[full_closer_side_index..-1].to_f

            full_closer_total = data.children[11].text.squish
            full_closer_total_index = full_closer_total.index(' ')
            full_closer_total = full_closer_total[full_closer_total_index..-1].to_f
            if away_type == 1
              temp = home_team
              home_team = away_team
              away_team = temp
              temp = away_score
              away_score = home_score
              home_score = temp
              full_closer_side = -full_closer_side
            end
            if @nba_nicknames[home_team]
            home_team = @nba_nicknames[home_team]
            end
            if @nba_nicknames[away_team]
              away_team = @nba_nicknames[away_team]
            end
            unless game = NbaClone.find_by(home_team: home_team, year: data_date.strftime("%Y"), date: data_date.strftime("%b %e") )
              unless game = NbaClone.find_by(away_team: away_team, year: data_date.strftime("%Y"), date: data_date.strftime("%b %e") )
                game = NbaClone.create(home_team: home_team, away_team: away_team, game_date: data_date, year: data_date.strftime("%Y"), date: data_date.strftime("%b %e"), time: data_date.strftime("%I:%M%p"), week: data_date.strftime("%a"), away_score: away_score, home_score: home_score, full_closer_side: full_closer_side, full_closer_total: full_closer_total )
              end
            end
            unless game.full_closer_side
              game.update(full_closer_side: full_closer_side, full_closer_total: full_closer_total)
            end
          end
        end
      end
    end
  end

  task :getRestScores => [:environment] do
    include Api
    Time.zone = 'Eastern Time (US & Canada)'
    index_date = Date.new(2000, 4, 18)
    while index_date <= Date.new(2000, 4, 19)
      game_date = index_date.strftime("%Y-%m-%d")
      url="https://www.basketball-reference.com/boxscores/index.fcgi?month=#{index_date.strftime('%m')}&day=#{index_date.strftime('%d')}&year=#{index_date.strftime('%Y')}"
      doc = download_document(url)
      puts url
      elements = doc.css(".game_summary")
      elements.each do |element|
        away_team = element.children[1].children[1].children[1].children[1].text
        away_score = element.children[1].children[1].children[1].children[3].text.to_i
        home_team = element.children[1].children[1].children[3].children[1].text
        home_score = element.children[1].children[1].children[3].children[3].text.to_i

        away_quarter_one = element.children[3].children[3].children[1].children[3].text.to_i
        away_quarter_two = element.children[3].children[3].children[1].children[4].text.to_i
        away_quarter_three = element.children[3].children[3].children[1].children[5].text.to_i
        away_quarter_four = element.children[3].children[3].children[1].children[6].text.to_i
        away_ot = 0
        if element.children[3].children[3].children[1].children[8]
          away_ot = element.children[3].children[3].children[1].children[7].text.to_i
        end
        
        home_quarter_one = element.children[3].children[3].children[3].children[3].text.to_i
        home_quarter_two = element.children[3].children[3].children[3].children[4].text.to_i
        home_quarter_three = element.children[3].children[3].children[3].children[5].text.to_i
        home_quarter_four = element.children[3].children[3].children[3].children[6].text.to_i
        home_ot = 0
        if element.children[3].children[3].children[3].children[8]
          home_ot = element.children[3].children[3].children[3].children[7].text.to_i
        end
        if @basket_names[away_team]
          away_team = @basket_names[away_team]
        end
        if @basket_names[home_team]
          home_team = @basket_names[home_team]
        end
        if game = NbaClone.find_by(home_team: home_team, away_team: away_team, game_date: game_date + ' 20:00:00 -0400')
          game.update(away_first_quarter: away_quarter_one, away_second_quarter: away_quarter_two, away_third_quarter: away_quarter_three, away_forth_quarter: away_quarter_four, away_score: away_score, home_first_quarter: home_quarter_one, home_second_quarter: home_quarter_two, home_third_quarter: home_quarter_three, home_forth_quarter: home_quarter_four, home_score: home_score, away_ot_quarter: away_ot, home_ot_quarter: home_ot)
        end
      end
      index_date = index_date + 1.days
    end
  end

  task :nbaplaybyplay => :environment do
    include Api
    games = Nba.where("year >= '2018' AND away_foul_first is null")
    puts games.count
    games.each do |game|
      url="http://www.espn.com/nba/playbyplay?gameId=#{game.game_id}"
      doc = download_document(url)
      puts url

      team_logo = doc.css(".home .team-info-logo .team-logo")
      home_abbr = 'undefined'
      if team_logo.size != 0
        logo_link = team_logo[0]['src']
        logo_link_end = logo_link.rindex('.png')
        logo_link_start = logo_link.rindex('/')
        home_abbr = logo_link[logo_link_start+1..logo_link_end-1].upcase
      end

      elements = doc.css(".accordion-item tr")
      puts elements.size
      home_fgm = 0
      home_fga = 0
      home_ptm = 0
      home_pta = 0
      home_ftm = 0
      home_fta = 0
      home_to = 0
      home_pf = 0
      home_or = 0
      home_stl = 0
      home_blk = 0
      away_fgm = 0
      away_fga = 0
      away_ptm = 0
      away_pta = 0
      away_ftm = 0
      away_fta = 0
      away_to = 0
      away_pf = 0
      away_or = 0
      away_stl = 0
      away_blk = 0
      elements.each_with_index do |element, index|
        next if element.children[0].text.squish == 'time'
        if element.children[0].text.squish == '0.0' && element.children[2].text.include?('End') && element.children[2].text.include?('2nd Quarter')
          game.update(
            home_fga_first: home_fga + home_pta,
            home_fgm_first: home_fgm + home_ptm,
            home_ptm_first: home_ptm,
            home_pta_first: home_pta,
            home_fta_first: home_fta,
            home_ftm_first: home_ftm,
            home_or_first: home_or,
            home_to_first: home_to,
            home_stl_first: home_stl,
            home_blk_first: home_blk,
            home_foul_first: home_pf,
            away_fga_first: away_fga + away_pta,
            away_fgm_first: away_fgm + away_ptm,
            away_ptm_first: away_ptm,
            away_pta_first: away_pta,
            away_fta_first: away_fta,
            away_ftm_first: away_ftm,
            away_or_first: away_or,
            away_to_first: away_to,
            away_foul_first: away_pf,
            away_stl_first: away_stl,
            away_blk_first: away_blk
          )
          home_fgm = 0
          home_fga = 0
          home_ptm = 0
          home_pta = 0
          home_ftm = 0
          home_fta = 0
          home_to = 0
          home_pf = 0
          home_or = 0
          home_stl = 0
          home_blk = 0
          away_fgm = 0
          away_fga = 0
          away_ptm = 0
          away_pta = 0
          away_ftm = 0
          away_fta = 0
          away_to = 0
          away_pf = 0
          away_or = 0
          away_stl = 0
          away_blk = 0
        end
        logo_element = element.children[1]
        team_abbr = 'undefined'
        if logo_element.children.size != 0
          logo_link = logo_element.children[0]['src']
          logo_link_end = logo_link.rindex('.png')
          logo_link_start = logo_link.rindex('/')
          team_abbr = logo_link[logo_link_start+1..logo_link_end-1].upcase
        end
        compare_string = element.children[2].text.downcase
        if compare_string.include?("offensive rebound") && compare_string.exclude?(game.home_team.downcase) && compare_string.exclude?(game.away_team.downcase)
          if team_abbr == home_abbr
            home_or = home_or + 1
          else
            away_or = away_or + 1
          end
        elsif compare_string.include?("steal")
          if team_abbr == home_abbr
            home_stl = home_stl + 1
          else
            away_stl = away_stl + 1
          end
        elsif compare_string.include?("foul") || compare_string.include?("offensive charge")
          if compare_string.exclude?("technical foul") && compare_string.exclude?("illegal defense foul")
            if team_abbr == home_abbr
              home_pf = home_pf + 1
            else
              away_pf = away_pf + 1
            end
          end
        elsif compare_string.include?("turnover") && compare_string.exclude?("shot clock turnover") && compare_string.exclude?("8 second turnover")
          if team_abbr == home_abbr
            home_to = home_to + 1
          else
            away_to = away_to + 1
          end
        elsif compare_string.include?("misses") || compare_string.include?("missed")
          if compare_string.include?("three")
            if team_abbr == home_abbr
              home_pta = home_pta + 1
            else
              away_pta = away_pta + 1
            end
          elsif compare_string.include?("throw")
            if team_abbr == home_abbr
              home_fta = home_fta + 1
            else
              away_fta = away_fta + 1
            end
          else
            if compare_string.include?("foot step back jumpshot")
              end_index = compare_string.index("foot step back jumpshot")
              start_index = compare_string.rindex(" ", end_index)
              if compare_string[start_index+1..end_index-1].to_i > 22
                if team_abbr == home_abbr
                  home_pta = home_pta + 1
                else
                  away_pta = away_pta + 1
                end
              else
                if team_abbr == home_abbr
                  home_fga = home_fga + 1
                else
                  away_fga = away_fga + 1
                end
              end
            else
              if team_abbr == home_abbr
                home_fga = home_fga + 1
              else
                away_fga = away_fga + 1
              end
            end
          end
        elsif compare_string.include?("makes") || compare_string.include?("made")
          if compare_string.include?("three")
            if team_abbr == home_abbr
              home_pta = home_pta + 1
              home_ptm = home_ptm + 1
            else
              away_pta = away_pta + 1
              away_ptm = away_ptm + 1
            end
          elsif compare_string.include?("throw")
            if team_abbr == home_abbr
              home_fta = home_fta + 1
              home_ftm = home_ftm + 1
            else
              away_fta = away_fta + 1
              away_ftm = away_ftm + 1
            end
          else
            currentScore = element.children[3].text
            previousScore = elements[index-1].children[3].text
            previousScore = elements[index-2].children[3].text if previousScore == 'SCORE'
            diff = 0
            currentIndex = currentScore.index('-')
            currentFirstScore = currentScore[0..currentIndex-1].to_i
            currentSecondScore = currentScore[currentIndex+1..-1].to_i
            previousIndex = previousScore.index('-')
            previousFirstScore = previousScore[0..previousIndex-1].to_i
            previousSecondScore = previousScore[previousIndex+1..-1].to_i
            if currentFirstScore == previousFirstScore && currentSecondScore != previousSecondScore
              diff = currentSecondScore - previousSecondScore
            elsif currentFirstScore != previousFirstScore && currentSecondScore == previousSecondScore
              diff = currentFirstScore - previousFirstScore
            end
            if diff == 3 && (compare_string.include?("foot step back jumpshot") || compare_string.include?("foot jump bank shot"))
              if team_abbr == home_abbr
                home_pta = home_pta + 1
                home_ptm = home_ptm + 1
              else
                away_pta = away_pta + 1
                away_ptm = away_ptm + 1
              end
            else
              if team_abbr == home_abbr
                home_fga = home_fga + 1
                home_fgm = home_fgm + 1
              else
                away_fga = away_fga + 1
                away_fgm = away_fgm + 1
              end
            end
          end
        elsif compare_string.include?("block")
          if team_abbr == home_abbr
            home_blk = home_blk + 1
          else
            away_blk = away_blk + 1
          end
          if compare_string.include?("three")
            if team_abbr == home_abbr
              home_pta = home_pta + 1
            else
              away_pta = away_pta + 1
            end
          else
            if team_abbr == home_abbr
              home_fga = home_fga + 1
            else
              away_fga = away_fga + 1
            end
          end
        elsif compare_string.include?("bad pass") || compare_string.include?("traveling") || compare_string.include?("lost ball")
          if team_abbr == home_abbr
            home_to = home_to + 1
          else
            away_to = away_to + 1
          end
        end
      end
      game.update(
        home_fga_second: home_fga + home_pta,
        home_fgm_second: home_fgm + home_ptm,
        home_ptm_second: home_ptm,
        home_pta_second: home_pta,
        home_fta_second: home_fta,
        home_ftm_second: home_ftm,
        home_or_second: home_or,
        home_to_second: home_to,
        home_stl_second: home_stl,
        home_blk_second: home_blk,
        home_foul_second: home_pf,
        away_fga_second: away_fga + away_pta,
        away_fgm_second: away_fgm + away_ptm,
        away_ptm_second: away_ptm,
        away_pta_second: away_pta,
        away_fta_second: away_fta,
        away_ftm_second: away_ftm,
        away_or_second: away_or,
        away_to_second: away_to,
        away_stl_second: away_stl,
        away_blk_second: away_blk,
        away_foul_second: away_pf
      )
    end
  end

  task :nbaplaybyplayfix => :environment do
    include Api
    games = Nba.where("year >= '2010' AND away_stl_first is null")
    puts games.count
    games.each do |game|
      url="http://www.espn.com/nba/playbyplay?gameId=#{game.game_id}"
      doc = download_document(url)
      puts url
      next unless doc

      team_logo = doc.css(".home .team-info-logo .team-logo")
      home_abbr = 'undefined'
      if team_logo.size != 0
        logo_link = team_logo[0]['src']
        logo_link_end = logo_link.rindex('.png')
        logo_link_start = logo_link.rindex('/')
        home_abbr = logo_link[logo_link_start+1..logo_link_end-1].upcase
      end

      elements = doc.css(".accordion-item tr")
      puts elements.size
      home_stl = 0
      home_blk = 0
      away_stl = 0
      away_blk = 0
      elements.each_with_index do |element, index|
        next if element.children[0].text.squish == 'time'
        if element.children[0].text.squish == '0.0' && element.children[2].text.include?('End') && element.children[2].text.include?('2nd Quarter')
          game.update(
              home_stl_first: home_stl,
              home_blk_first: home_blk,
              away_stl_first: away_stl,
              away_blk_first: away_blk
          )
          home_stl = 0
          home_blk = 0
          away_stl = 0
          away_blk = 0
        end
        logo_element = element.children[1]
        team_abbr = 'undefined'
        if logo_element.children.size != 0
          logo_link = logo_element.children[0]['src']
          logo_link_end = logo_link.rindex('.png')
          logo_link_start = logo_link.rindex('/')
          team_abbr = logo_link[logo_link_start+1..logo_link_end-1].upcase
        end
        compare_string = element.children[2].text.downcase
        if compare_string.include?("steal")
          if team_abbr == home_abbr
            home_stl = home_stl + 1
          else
            away_stl = away_stl + 1
          end
        elsif compare_string.include?("block")
          if team_abbr == home_abbr
            home_blk = home_blk + 1
          else
            away_blk = away_blk + 1
          end
        end
      end
      game.update(
          home_stl_second: home_stl,
          home_blk_second: home_blk,
          away_stl_second: away_stl,
          away_blk_second: away_blk
      )
    end
  end

  task :addPlayerToNba => :environment do
    include Api
    games = Nba.where("home_player8_name is null")
    puts games.size
    games.each do |game|
      game_id = game.game_id
      puts game_id
      url = "http://www.espn.com/nba/boxscore?gameId=#{game_id}"
      doc = download_document(url)

      away_players = doc.css('#gamepackage-boxscore-module .gamepackage-away-wrap tbody tr')
      (0...8).each do |element|
        next unless away_players[element]
        slice = away_players[element]

        if slice.children[0].children.size > 1
          link = slice.children[0].children[0]['href']
          next unless link
          puts link
          page = download_document(link)
          player_name = page.css("h1")[0].text
          birthday = page.css(".player-metadata")[0]
          if birthday.children[0]
            birthday = birthday.children[0].children[1].text
          else
            birthday = nil
          end
        else
          player_name = slice.children[0].text
          birthday = ""
        end
        player_name_key = "away_player" + (element + 1).to_s + "_name"
        player_birthday_key = "away_player" + (element + 1).to_s + "_birthday"
        game.update(
            player_name_key => player_name,
            player_birthday_key => birthday
        )
      end

      home_players = doc.css('#gamepackage-boxscore-module .gamepackage-home-wrap tbody tr')
      (0...8).each do |element|
        next unless home_players[element]
        slice = home_players[element]
        if slice.children[0].children.size > 1
          link = slice.children[0].children[0]['href']
          next unless link
          page = download_document(link)
          player_name = page.css("h1")[0].text
          birthday = page.css(".player-metadata")[0]
          if birthday.children[0]
            birthday = birthday.children[0].children[1].text
          else
            birthday = nil
          end
        else
          player_name = slice.children[0].text
          birthday = ""
        end
        player_name_key = "home_player" + (element + 1).to_s + "_name"
        player_birthday_key = "home_player" + (element + 1).to_s + "_birthday"
        game.update(
            player_name_key => player_name,
            player_birthday_key => birthday
        )
      end
    end
  end


  @basket_names = {
    'Charlotte' => 'New Orleans',
    'New Jersey' => 'Brooklyn',
    'LA Clippers' => 'LAC',
    'LA Lakers' => 'LAL',
    'Seattle' => 'Oklahoma City',
    'Vancouver' => 'Memphis'
  }

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

  @basket_nicknames = {
    'BKN' => 'BRK',
    'CHA' => 'CHO',
    'PHX' => 'PHO',
    'GS' => 'GSW',
    'NO' => 'NOP',
    'NY' => 'NYK',
    'WSH' => 'WAS',
    'SA' => 'SAS'
  }

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
		"L.A. Clippers" => "LAC",
    "LA Clippers" => "LAC",
    "LA Lakers" => "LAL"
	}

	@player_name = {
		"T. Prince" => "T. Waller-Prince",
		"T.J. McConnell" => "T. McConnell",
		"J.J. Barea" => "J. Barea",
		"T.J. Leaf" => "T. Leaf",
		"D.J. Augustin" => "D. Augustin",
		"C.J. Williams" => "C. Williams",
		"D.J. Wilson" => "D. Wilson"
	}

  @player_another_name = {
    'Taurean Prince' => 'Taurean Waller-Prince',
    'Maximilian Kleber' => 'Maxi Kleber',
    'Walt Lemon' => 'Walt Lemon, Jr'
  }

  @team_names = {
    'Atlanta' => 'Atlanta',
    'Boston' => 'Boston',
    'Brooklyn' => 'Brooklyn',
    'Charlotte' => 'Charlotte',
    'Chicago' => 'Chicago',
    'Cleveland' => 'Cleveland',
    'Dallas' => 'Dallas',
    'Denver' => 'Denver',
    'Detroit' => 'Detroit',
    'Golden State' => 'Golden State',
    'Houston' => 'Houston',
    'Indiana' => 'Indiana',
    'LAC' => 'LA Clippers',
    'LAL' => 'LA Lakers',
    'Memphis' => 'Memphis',
    'Miami' => 'Miami',
    'Milwaukee' => 'Milwaukee',
    'Minnesota' => 'Minnesota',
    'New Orleans' => 'New Orleans',
    'New York' => 'New York',
    'Oklahoma City' => 'Okla City',
    'NO/Oklahoma City' => 'Okla City',
    'Orlando' => 'Orlando',
    'Philadelphia' => 'Philadelphia',
    'Phoenix' => 'Phoenix',
    'Portland' => 'Portland',
    'Sacramento' => 'Sacramento',
    'San Antonio' => 'San Antonio',
    'Toronto' => 'Toronto',
    'Utah' => 'Utah',
    'Washington' => 'Washington'
  }

  @home_team = {
    'team404169.html' => 'Boston',
    'team404117.html' => 'Brooklyn',
    'team404288.html' => 'New York',
    'team404083.html' => 'Philadelphia',
    'team404330.html' => 'Toronto',
    'team404198.html' => 'Chicago',
    'team404213.html' => 'Cleveland',
    'team404153.html' => 'Detroit',
    'team404155.html' => 'Indiana',
    'team404011.html' => 'Milwaukee',
    'team404085.html' => 'Atlanta',
    'team664421.html' => 'Charlotte',
    'team404171.html' => 'Miami',
    'team404013.html' => 'Orlando',
    'team404067.html' => 'Washington',
    'team404065.html' => 'Denver',
    'team403995.html' => 'Minnesota',
    'team404316.html' => 'Oklahoma City',
    'team403993.html' => 'Portland',
    'team404031.html' => 'Utah',
    'team404119.html' => 'Golden State',
    'team404135.html' => 'L.A. Clippers',
    'team403977.html' => 'L.A. Lakers',
    'team404029.html' => 'Phoenix',
    'team403975.html' => 'Sacramento',
    'team404047.html' => 'Dallas',
    'team404137.html' => 'Houston',
    'team404049.html' => 'Memphis',
    'team404101.html' => 'New Orleans',
    'team404302.html' => 'San Antonio'
  }

  @player_nicknames = {
    'JT Orr' => 'J.T. Orr'
  }

  @match = {
      'PHX' => 'PHO',
      'UTAH' => 'UTA',
      'WSH' => 'WAS'
  }
end