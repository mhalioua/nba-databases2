namespace :nba do
	task :getInjury => :environment do
    include Api
    Injury.destroy_all()
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
          element = Injury.create(team: team, link: link, date: date, name: name, status: status, text: text)
        end
      end
    end

    injuries = Injury.all
    injuries.each do |injury|
      injury_date = Date.strptime(injury.date, "%b %e")
      injury_players = Player.where("player_fullname = ? AND game_date >= ?", injury.name, injury_date)
      if injury_players.size > 0
        Injury.delete(injury.id)
      end
    end
	end
  
	task :daily => :environment do
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

		Rake::Task["nba:getFirstLines"].invoke
		Rake::Task["nba:getFirstLines"].reenable

		link = "https://www.sportsbookreview.com/betting-odds/nba-basketball/2nd-half/?date="
		Rake::Task["nba:getSecondLines"].invoke("second", link)
		Rake::Task["nba:getSecondLines"].reenable

		link = "https://www.sportsbookreview.com/betting-odds/nba-basketball/?date="
		Rake::Task["nba:getSecondLines"].invoke("full", link)
		Rake::Task["nba:getSecondLines"].reenable

		link = "https://www.sportsbookreview.com/betting-odds/nba-basketball/totals/1st-half/?date="
		Rake::Task["nba:getSecondLines"].invoke("firstTotal", link)
		Rake::Task["nba:getSecondLines"].reenable

		link = "https://www.sportsbookreview.com/betting-odds/nba-basketball/totals/2nd-half/?date="
		Rake::Task["nba:getSecondLines"].invoke("secondTotal", link)
		Rake::Task["nba:getSecondLines"].reenable

		link = "https://www.sportsbookreview.com/betting-odds/nba-basketball/totals/?date="
		Rake::Task["nba:getSecondLines"].invoke("fullTotal", link)
		Rake::Task["nba:getSecondLines"].reenable

		Rake::Task["nba:gettg"].invoke
		Rake::Task["nba:gettg"].reenable

		Rake::Task["nba:getPlayer"].invoke
		Rake::Task["nba:getPlayer"].reenable

		Rake::Task["nba:getUpdateTG"].invoke
		Rake::Task["nba:getUpdateTG"].reenable

		Rake::Task["nba:getUpdatePoss"].invoke
		Rake::Task["nba:getUpdatePoss"].reenable
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
               team            =       slice.children[index[:team]].text
               current         =       slice.children[index[:current]].text.to_f
               last_three      =       slice.children[index[:last_three]].text.to_f
               last_one        =       slice.children[index[:last_one]].text.to_f
               home            =       slice.children[index[:home]].text.to_f
               away            =       slice.children[index[:away]].text.to_f
               last            =       slice.children[index[:last]].text.to_f

               unless element = Team.find_by(team: team)
                       element = Team.create(team: team)
               end
   			element.update(rebound_current: current, rebound_last_three: last_three, rebound_last_one: last_one, rebound_home: home, rebound_away: away, rebound_last: last)
        end

       url = "https://www.teamrankings.com/nba/stat/possessions-per-game"
       doc = download_document(url)
       elements = doc.css(".datatable tbody tr")

       elements.each do |slice|
               team            =       slice.children[index[:team]].text
               current         =       slice.children[index[:current]].text.to_f
               last_three      =       slice.children[index[:last_three]].text.to_f
               last_one        =       slice.children[index[:last_one]].text.to_f
               home            =       slice.children[index[:home]].text.to_f
               away            =       slice.children[index[:away]].text.to_f
               last            =       slice.children[index[:last]].text.to_f

               unless element = Team.find_by(team: team)
                       element = Team.create(team: team)
               end
           element.update(possessions_current: current, possessions_last_three: last_three, possessions_last_one: last_one, possessions_home: home, possessions_away: away, possessions_last: last)
        end

       url = "https://www.teamrankings.com/nba/stat/steals-per-game"
       doc = download_document(url)
       elements = doc.css(".datatable tbody tr")

       elements.each do |slice|
               team            =       slice.children[index[:team]].text
               current         =       slice.children[index[:current]].text.to_f
               last_three      =       slice.children[index[:last_three]].text.to_f
               last_one        =       slice.children[index[:last_one]].text.to_f
               home            =       slice.children[index[:home]].text.to_f
               away            =       slice.children[index[:away]].text.to_f
               last            =       slice.children[index[:last]].text.to_f

               unless element = Team.find_by(team: team)
                       element = Team.create(team: team)
               end
   			element.update(steal_current: current, steal_last_three: last_three, steal_last_one: last_one, steal_home: home, steal_away: away, steal_last: last)
       end

       url = "https://www.teamrankings.com/nba/stat/blocks-per-game"
       doc = download_document(url)
       elements = doc.css(".datatable tbody tr")

       elements.each do |slice|
               team            =       slice.children[index[:team]].text
               current         =       slice.children[index[:current]].text.to_f
               last_three      =       slice.children[index[:last_three]].text.to_f
               last_one        =       slice.children[index[:last_one]].text.to_f
               home            =       slice.children[index[:home]].text.to_f
               away            =       slice.children[index[:away]].text.to_f
               last            =       slice.children[index[:last]].text.to_f

               unless element = Team.find_by(team: team)
                       element = Team.create(team: team)
               end
           element.update(block_current: current, block_last_three: last_three, block_last_one: last_one, block_home: home, block_away: away, block_last: last)
        end

       url = "https://www.teamrankings.com/nba/stat/turnovers-per-game"
       doc = download_document(url)
       elements = doc.css(".datatable tbody tr")

       elements.each do |slice|
               team            =       slice.children[index[:team]].text
               current         =       slice.children[index[:current]].text.to_f
               last_three      =       slice.children[index[:last_three]].text.to_f
               last_one        =       slice.children[index[:last_one]].text.to_f
               home            =       slice.children[index[:home]].text.to_f
               away            =       slice.children[index[:away]].text.to_f
               last            =       slice.children[index[:last]].text.to_f

               unless element = Team.find_by(team: team)
                       element = Team.create(team: team)
               end
           element.update(turnover_current: current, turnover_last_three: last_three, turnover_last_one: last_one, turnover_home: home, turnover_away: away, turnover_last: last)
        end

        url = "http://www.espn.com/nba/standings/_/group/league"
        doc = download_document(url)
        teams = doc.css("abbr")
        elements = doc.css("tr")
        puts elements.size
        elements.each_with_index do |slice, index|
                   team_abbr  =       teams[index].text
                   w          =       slice.children[1].text
                   l          =       slice.children[2].text
                   ppg        =       slice.children[9].text.to_f
                   opp        =       slice.children[10].text.to_f
                   diff       =       slice.children[11].text.to_f

                   if element = Team.find_by(abbr: team_abbr)
                    element.update(record_won: w, record_lost: l, record_ppg: ppg, record_opp: opp, record_diff: diff)
                   end
        end

       url = "https://www.teamrankings.com/nba/stat/opponent-1st-half-points-per-game"
       doc = download_document(url)
       elements = doc.css(".datatable tbody tr")

       elements.each do |slice|
               team            =       slice.children[index[:team]].text
               current         =       slice.children[index[:current]].text.to_f
               last_three      =       slice.children[index[:last_three]].text.to_f
               last_one        =       slice.children[index[:last_one]].text.to_f
               home            =       slice.children[index[:home]].text.to_f
               away            =       slice.children[index[:away]].text.to_f
               last            =       slice.children[index[:last]].text.to_f

               unless element = Team.find_by(team: team)
                       element = Team.create(team: team)
               end
           element.update(opponentfirst_current: current, opponentfirst_last_three: last_three, opponentfirst_last_one: last_one, opponentfirst_home: home, opponentfirst_away: away, opponentfirst_last: last)
        end

       url = "https://www.teamrankings.com/nba/stat/opponent-2nd-half-points-per-game"
       doc = download_document(url)
       elements = doc.css(".datatable tbody tr")

       elements.each do |slice|
               team            =       slice.children[index[:team]].text
               current         =       slice.children[index[:current]].text.to_f
               last_three      =       slice.children[index[:last_three]].text.to_f
               last_one        =       slice.children[index[:last_one]].text.to_f
               home            =       slice.children[index[:home]].text.to_f
               away            =       slice.children[index[:away]].text.to_f
               last            =       slice.children[index[:last]].text.to_f

               unless element = Team.find_by(team: team)
                       element = Team.create(team: team)
               end
           element.update(opponentsecond_current: current, opponentsecond_last_three: last_three, opponentsecond_last_one: last_one, opponentsecond_home: home, opponentsecond_away: away, opponentsecond_last: last)
        end

        url = "https://www.teamrankings.com/nba/stat/1st-half-points-per-game"
       doc = download_document(url)
       elements = doc.css(".datatable tbody tr")

       elements.each do |slice|
               team            =       slice.children[index[:team]].text
               current         =       slice.children[index[:current]].text.to_f
               last_three      =       slice.children[index[:last_three]].text.to_f
               last_one        =       slice.children[index[:last_one]].text.to_f
               home            =       slice.children[index[:home]].text.to_f
               away            =       slice.children[index[:away]].text.to_f
               last            =       slice.children[index[:last]].text.to_f

               unless element = Team.find_by(team: team)
                       element = Team.create(team: team)
               end
           element.update(first_current: current, first_last_three: last_three, first_last_one: last_one, first_home: home, first_away: away, first_last: last)
        end

        url = "https://www.teamrankings.com/nba/stat/2nd-half-points-per-game"
       doc = download_document(url)
       elements = doc.css(".datatable tbody tr")

       elements.each do |slice|
               team            =       slice.children[index[:team]].text
               current         =       slice.children[index[:current]].text.to_f
               last_three      =       slice.children[index[:last_three]].text.to_f
               last_one        =       slice.children[index[:last_one]].text.to_f
               home            =       slice.children[index[:home]].text.to_f
               away            =       slice.children[index[:away]].text.to_f
               last            =       slice.children[index[:last]].text.to_f

               unless element = Team.find_by(team: team)
                       element = Team.create(team: team)
               end
           element.update(second_current: current, second_last_three: last_three, second_last_one: last_one, second_home: home, second_away: away, second_last: last)
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
	  		if element.size > 3
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
	  	game.update(away_team: away_team, home_team: home_team, home_abbr: home_abbr, away_abbr: away_abbr, game_date: date, year: addingDate.strftime("%Y"), date: addingDate.strftime("%b %e"), time: addingDate.strftime("%I:%M%p"), week: addingDate.strftime("%a"), away_mins: away_mins_value, away_fga: away_fga_value, away_fta: away_fta_value, away_toValue: away_to_value, away_orValue: away_or_value, home_mins: home_mins_value, home_fga: home_fga_value, home_fta: home_fta_value, home_toValue: home_to_value, home_orValue: home_or_value, home_timezone: home_timezone, home_win_rank: home_win_rank, home_ppg_rank: home_ppg_rank, home_oppppg_rank: home_oppppg_rank, away_timezone: away_timezone, away_win_rank: away_win_rank, away_ppg_rank: away_ppg_rank, away_oppppg_rank: away_oppppg_rank)
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
					home_fta_value = home_value.children[4].text
					home_fta_index = home_fta_value.index('-')
					home_fta_value = home_fta_index ? home_fta_value[home_fta_index+1..-1].to_i : 0
					home_or_value = home_value.children[5].text.to_i
          home_stl_value = home_value.children[9].text.to_i
          home_blk_value = home_value.children[10].text.to_i
				end

		  		game.update(first_away_fga: away_fga_value, first_away_fta: away_fta_value, first_away_toValue: away_to_value, first_away_orValue: away_or_value, first_home_fga: home_fga_value, first_home_fta: home_fta_value, first_home_toValue: home_to_value, first_home_orValue: home_or_value, first_away_stl: away_stl_value, first_away_blk: away_blk_value, first_home_stl: home_stl_value, first_home_blk: home_blk_value)
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
        pts_value = slice.children[14].text.to_i
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
	            player.update(position: position, state: index + 1, poss: poss, mins: mins_value, fga: fga_value, fta:fta_value, toValue: to_value, orValue: or_value, height: height, link: link, game_date: game.game_date, ptsValue: pts_value )
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
        pts_value = slice.children[14].text.to_i
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
        player.update(position: position, state: index + 1, poss: poss, mins: mins_value, fga: fga_value, fta:fta_value, toValue: to_value, orValue: or_value, height: height, link: link, game_date: game.game_date,  ptsValue: pts_value )
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
		            player_element.update(ortg: ortg, drtg: drtg, count: count, player_link: player_link, player_fullname: player.children[1].children[0].text)
				end
				if index == 3
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
				count = 0
				mins_min = 100
				mins_max = 0
				last_players = Player.where("game_date >= ? AND game_date <= ? AND player_name = ?", Date.new(2017, 10 ,20), player.game_date, player.player_name).or(Player.where("game_date <= ? AND player_name = ?", Date.new(2017, 6 ,18), player.player_name)).order('game_date DESC')
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
				sum_mins = sum_mins - mins_min - mins_max
        if sum_mins < 0
          sum_mins = 0
        end
				player.update(sum_poss: sum_poss, team_poss: team_poss, possession: possession.join(","), sum_mins: sum_mins)
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

					player_name_index = player_name.index(" II")
					player_name = player_name_index ? player_name[0..player_name_index-1] : player_name

					player_name_index = player_name.index(" III")
					player_name = player_name_index ? player_name[0..player_name_index-1] : player_name

					if @player_name[player_name]
						player_name = @player_name[player_name]
					end
					
					ortg = 0
					drtg = 0
          count = 0
          player_link = ""
          player_fullname = ""
          player_elements = Tg.where("player_name = ? AND year >= 2017", player_name)
          player_elements.each do |player_element|
            player_count = player_element.count ? player_element.count : 1
            count = count + player_count
            ortg = ortg + player_count * (player_element.ortg ? player_element.ortg : 0)
            drtg = drtg + player_count * (player_element.drtg ? player_element.drtg : 0)
            player_link = player_element.player_link
            player_fullname = player_element.player_fullname
          end
					ortg = (ortg.to_f / count).round(1)
					drtg = (drtg.to_f / count).round(1)
					player.update(ortg: ortg, drtg: drtg, player_link: player_link, player_fullname: player_fullname)
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

      home_pg_players = home_last.players.where("team_abbr = ? AND position = 'PG' AND player_name <> 'TEAM'", home_flag).order(:state)
      away_pg_players = away_last.players.where("team_abbr = ? AND position = 'PG' AND player_name <> 'TEAM'", away_flag).order(:state)
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

      home_pg_players = home_last.players.where("team_abbr = ? AND position = 'SG' AND player_name <> 'TEAM'", home_flag).order(:state)
      away_pg_players = away_last.players.where("team_abbr = ? AND position = 'SG' AND player_name <> 'TEAM'", away_flag).order(:state)
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

      home_pg_players = home_last.players.where("team_abbr = ? AND position = 'PF' AND player_name <> 'TEAM'", home_flag).or(home_last.players.where("team_abbr = ? AND position = 'C' AND player_name <> 'TEAM'", home_flag)).order(:state)
      away_pg_players = away_last.players.where("team_abbr = ? AND position = 'PF' AND player_name <> 'TEAM'", away_flag).or(away_last.players.where("team_abbr = ? AND position = 'C' AND player_name <> 'TEAM'", away_flag)).order(:state)
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

      home_pg_players = home_last.players.where("team_abbr = ? AND position = 'SF' AND player_name <> 'TEAM'", home_flag).order(:state)
      away_pg_players = away_last.players.where("team_abbr = ? AND position = 'SF' AND player_name <> 'TEAM'", away_flag).order(:state)
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
    player_link = player_link[player_link_start+1..player_link_end-1]
    home_link = player_link
    away_full_name = away_pg_player.player_fullname
    away_full_name_link = away_full_name.gsub(' ', '+')
    player_link = away_pg_player.player_link
    player_link_end = player_link.rindex(".")
    player_link_start = player_link.rindex("/")
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


	task :atest => :environment do
		require 'csv'

		items = []
		CSV.foreach(Rails.root.join('fullseason.csv'), headers: true) do |row|
			Fullseason.create(row.to_h)
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
      puts game.inspect
      
    end
  end

  task :teaminfo => :environment do
    include Api
    url = "http://www.espn.com/nba/standings/_/season/2017/sort/wins/group/league"
    doc = download_document(url)
    elements = doc.css("abbr")
    puts elements.length
    elements.each_with_index do |element, index|
      unless team = Team.find_by(abbr: element.text)
        team = Team.create(abbr: element.text)
      end
      team.update(order_one_sixteen: index + 1)
    end

    url = "http://www.espn.com/nba/standings/_/season/2017/sort/avgpointsfor/group/league"
    doc = download_document(url)
    elements = doc.css("abbr")
    puts elements.length
    elements.each_with_index do |element, index|
      unless team = Team.find_by(abbr: element.text)
        team = Team.create(abbr: element.text)
      end
      team.update(order_two_sixteen: index + 1)
    end

    url = "http://www.espn.com/nba/standings/_/season/2017/sort/avgpointsagainst/group/league"
    doc = download_document(url)
    elements = doc.css("abbr")
    puts elements.length
    elements.each_with_index do |element, index|
      unless team = Team.find_by(abbr: element.text)
        team = Team.create(abbr: element.text)
      end
      team.update(order_thr_sixteen: index + 1)
    end
  end

  task :getpg => :environment do
    include Api
    Time.zone = 'Eastern Time (US & Canada)'

    games = Nba.where("pg_away_one_name is null")
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

  task :getPlayerClone => [:environment] do
    include Api
    puts "----------Get Players----------"
    games = Nba.all
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
        pts_value = slice.children[14].text.to_i
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
              player.update(position: position, state: index + 1, poss: poss, mins: mins_value, fga: fga_value, fta:fta_value, toValue: to_value, orValue: or_value, height: height, link: link, game_date: game.game_date, ptsValue: pts_value )
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
        pts_value = slice.children[14].text.to_i
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
        player.update(position: position, state: index + 1, poss: poss, mins: mins_value, fga: fga_value, fta:fta_value, toValue: to_value, orValue: or_value, height: height, link: link, game_date: game.game_date,  ptsValue: pts_value )
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
end