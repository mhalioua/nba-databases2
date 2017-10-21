namespace :nba do

	task :daily => :environment do
		date = Date.new(2016, 10, 25)
		while date < Date.new(2017, 6, 12)  do
			Rake::Task["nba:getDate"].invoke(date.strftime("%Y%m%d"))
			Rake::Task["nba:getDate"].reenable
			date = date + 7.days
		end

		
	end

	task :getDate, [:game_date] => [:environment] do |t, args|
		include Api
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

	  		url = "http://www.espn.com/nba/game?gameId=#{game_id}"
	  		doc = download_document(url)
			puts url
	  		element = doc.css(".game-date-time").first
	  		game_date = element.children[1]['data-date']
	  		game.update(away_team: away_team, home_team: home_team, home_abbr: home_abbr, away_abbr: away_abbr, game_date: game_date)
	  	end
	end

	task :getScore => [:environment] do
		include Api

		games = Nba.all
		games.each do |game|
			game_id = game.game_id

			url = "http://www.espn.com/nba/playbyplay?gameId=#{game_id}"
	  		doc = download_document(url)
			puts url

	  		element = doc.css("#gp-quarter-1 tr .combined-score")
	  		away_first_quarter = 0
	  		home_first_quarter = 0
	  		if element.size != 0
				value = element.last.text
				end_index = value.index(" ")
				away_first_quarter = value[0..end_index].to_i
				start_index = value.index("-") + 2
				home_first_quarter = value[start_index..-1].to_i
			end

			element = doc.css("#gp-quarter-2 tr .combined-score")
	  		away_second_quarter = away_first_quarter
	  		home_second_quarter = home_first_quarter
	  		if element.size != 0
				value = element.last.text
				end_index = value.index(" ")
				away_second_quarter = value[0..end_index].to_i
				start_index = value.index("-") + 2
				home_second_quarter = value[start_index..-1].to_i
			end

			element = doc.css("#gp-quarter-3 tr .combined-score")
	  		away_third_quarter = away_second_quarter
	  		home_third_quarter = home_second_quarter
	  		if element.size != 0
				value = element.last.text
				end_index = value.index(" ")
				away_third_quarter = value[0..end_index].to_i
				start_index = value.index("-") + 2
				home_third_quarter = value[start_index..-1].to_i
			end

			element = doc.css("#gp-quarter-4 tr .combined-score")
	  		away_forth_quarter = away_third_quarter
	  		home_forth_quarter = home_third_quarter
	  		if element.size != 0
				value = element.last.text
				end_index = value.index(" ")
				away_forth_quarter = value[0..end_index].to_i
				start_index = value.index("-") + 2
				home_forth_quarter = value[start_index..-1].to_i
			end

			element = doc.css("#gp-quarter-5 tr .combined-score")
	  		away_ot_quarter = away_forth_quarter
	  		home_ot_quarter = home_forth_quarter
	  		if element.size != 0
				value = element.last.text
				end_index = value.index(" ")
				away_ot_quarter = value[0..end_index].to_i
				start_index = value.index("-") + 2
				home_ot_quarter = value[start_index..-1].to_i
			end

			game.update(away_first_quarter: away_first_quarter, home_first_quarter: home_first_quarter, away_second_quarter: away_second_quarter - away_first_quarter, home_second_quarter: home_second_quarter - home_first_quarter, away_third_quarter: away_third_quarter - away_second_quarter, home_third_quarter: home_third_quarter - home_second_quarter, away_forth_quarter: away_forth_quarter - away_third_quarter, home_forth_quarter: home_forth_quarter - home_third_quarter, away_ot_quarter: away_ot_quarter - away_forth_quarter, home_ot_quarter: home_ot_quarter - home_forth_quarter, away_score: away_ot_quarter, home_score: home_ot_quarter, total_score: away_ot_quarter + home_ot_quarter, first_point: home_second_quarter + away_second_quarter, second_point: home_forth_quarter + away_forth_quarter - home_second_quarter - away_second_quarter, total_point: home_forth_quarter + away_forth_quarter)
		end
	end
end