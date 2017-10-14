require 'rufus-scheduler'

scheduler = Rufus::Scheduler::singleton

scheduler.every '10s' do
	include Api
  	games = Game.where(game_state: "6")
  	Rails.logger.info "10secs - #{games.size}"

  	games = []
		
	games.each do |game|
		game_link = "college-football"
		game_type = game.game_type
		if game_type == "NFL"
			game_link= "nfl"
		end
		game_id = game.game_id

        url = "http://www.espn.com/#{game_link}/matchup?gameId=#{game_id}"
		doc = download_document(url)
		Rails.logger.info url
		element = doc.css(".game-time").first
		game_status = element.text

  		game_state = 1
  		if game_status.include?("Half")
  			game_state = 0
  		end

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
		Rails.logger.info url
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
       
        unless score = game.scores.find_by(result: "Half")
          	score = game.scores.create(result: "Half")
        end

        if game_state == 1
        	game_time_index = game_status.index(" ")
        	game_status = game_status[0..game_time_index]
        	if game_status.index(":") == 1
        		game_status = "0" + game_status
        	end
        end
        score.update(game_status: game_status, home_team_total: home_team_total, away_team_total: away_team_total, home_team_rushing: home_team_rushing, away_team_rushing: away_team_rushing, home_result: home_result, away_result: away_result, home_car: home_car, home_ave_car: home_ave_car, home_rush_long: home_rush_long, home_c_att: home_c_att, home_ave_att: home_ave_att, home_total_play: home_total_play, home_play_yard: home_play_yard, home_sacks: home_sacks, away_car: away_car, away_ave_car: away_ave_car, away_rush_long: away_rush_long, away_c_att: away_c_att, away_ave_att: away_ave_att, away_total_play: away_total_play, away_play_yard: away_play_yard, away_sacks: away_sacks, home_pass_long: home_pass_long, away_pass_long: away_pass_long)
	    
		url = "http://www.espn.com/#{game_link}/playbyplay?gameId=#{game_id}"
  		doc = download_document(url)
  		check_img = doc.css(".accordion-header img")
  		first_drive = check_img.size

	  	if game.game_state == 1 && game_state == 0
	  		game_status = Time.now
	  	end
		game.update(game_state: game_state, game_status: game_status, first_drive: first_drive)
  	end
end