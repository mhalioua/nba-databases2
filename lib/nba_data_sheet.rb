class NbaDataSheet
	def self.generate_data_sheet(game_start_date,game_end_date)

    data_file_path = [Rails.root, "csv", "nba_data_sheet.xlsx"].join("/")
		package = Axlsx::Package.new
    workbook = package.workbook
    workbook.add_worksheet(name: 'MAIN (6)') do |sheet|
        
      
      header_red_cell = sheet.styles.add_style(bg_color: 'FF0000', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_cell_peach = sheet.styles.add_style(bg_color: 'FF8080', fg_color: '000000',:border => { :style => :thin, :color => 'D3D3D3'})
      header_color_mustard = sheet.styles.add_style(bg_color: 'FFCC00', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_green = sheet.styles.add_style(bg_color: '339966', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_skin = sheet.styles.add_style(bg_color: 'FFCC99', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_lightskin = sheet.styles.add_style(bg_color: 'FFE0C4', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_white = sheet.styles.add_style(bg_color: 'FFFFFF', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_seagreen = sheet.styles.add_style(bg_color: '33CCCC', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_lightpurple = sheet.styles.add_style(bg_color: 'CCCCFF', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_green2 = sheet.styles.add_style(bg_color: '99CC00', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_lightgreen = sheet.styles.add_style(bg_color: 'CCFFCC', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_orange = sheet.styles.add_style(bg_color: 'FF9900', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_darkorange = sheet.styles.add_style(bg_color: 'e9692c', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_skyblue = sheet.styles.add_style(bg_color: '8EE5EE', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_darkred = sheet.styles.add_style(bg_color: 'a52a2a', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_mildblue = sheet.styles.add_style(bg_color: '5190ED', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})      
      header_color_lightorange = sheet.styles.add_style(bg_color: 'FFCC99', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_purple = sheet.styles.add_style(bg_color: '9999FF', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_yellow = sheet.styles.add_style(bg_color: 'FFFF00', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_darkblue = sheet.styles.add_style(bg_color: '003366', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_lightyellow = sheet.styles.add_style(bg_color: 'FFFF99', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_lightblue = sheet.styles.add_style(bg_color: '99CCFF', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_black = sheet.styles.add_style(bg_color: '000000', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
      header_color_greenlast = sheet.styles.add_style(bg_color: '567E3A', fg_color: '000000', :border => { :style => :thin, :color => 'D3D3D3'})
          
      sheet.add_row [nil, "Year", "Date", "Time", "Week", "tv2", "tv", "count", "is last game home", "last", "next", "is next game home",
           "Away Team", nil, "TRUE", "last city", "next city", "away_ppg_rank", "away_oppppg_rank", "FROM", "TO", "1Q", "2Q",
           "1h total", "3Q", nil, "4Q", "OT", nil, "next", "FLY", "last", "FLY", "Home Team", "home_win_rank", nil, "last city", "next city",
           "home_ppg_rank", "home_oppppg_rank", "Timezone", "1Q", "2Q", nil, "3Q", nil, "4Q", "2h total", "OT", "lead @ HALF", "3RD Q lead",
           "final", "TRUE 2H PTS", "4TH Q", "road", "home", "total", "1H Point", "2H Point", "1q", "2q", "3q", "4q", "Total Point",
           "1h", "2h", "f", "1H Line Total", "2H Line Total", "FG Line Total", "1H", "2h", "fg", "1H Side", "2H Side", "XXX",
           "FG Side", "did home team play over time last game", "did road team play over time last game", "PtsPerPoss",
           "last 1h away under", "last 1h away over", " last 1h away %", "last 1h home under", "last 1h home over",
           "last 1h home %", "next 1h away under", "next 1h away over", "next 1h away %", "next 1h home under", "next 1h home over",
           "next 1h home %", "last 2h away under", "last 2h away over", " last 2h away %", "last 2h home under", "last 2h home over",
           "last 2h home %", "next 2h away under", "next 2h away over", "next 2h away %", "next 2h home under", "next 2h home over",
           "next 2h home %", "last fg away under", "last fg away over", " last fg away %", "last fg home under", "last fg home over",
           "last fg home %", "next fg away under", "next fg away over", "next fg away %", "next fg home under", "next fg home over",
           "next fg home %", "1hawayFGA", "1hawayFG", "1hawayFG %", "1hawayFTA", "1haway3PA", "1haway3P", "1haway3P %",
           "1haway OR's", "1hawaySTEALS", "1hawayBLOCKS", "1haway TO's", "OR+BL+STl-TO", "1hhomeFGA", "1hhomeFG",
           "1hhomeFG %", "1hhomeFTA", "1hhome3PA", "1hhome3P", "1hhome3P %", "1hhome OR's", "1hhomeSTEALS", "1hhomeBLOCKS",
           "1hhome TO's", "OR+BL+STl-TO", "FG% diff", "3P% diff", "OR diff", "TO diff", "CE-CQ", "1h home possession",
           "1h road possession", "1h total possession", "2h home possession", "2h road possession", "2h total possession",
           "pace", "away_ortg", "home_ortg", "away_last_home", "away_next_home", "DM  + DN", nil, "home teams last road game",
           "home teams next road game", "DQ+DR", 99.09, 97.01, "1h points", "2h points", "total points", "fg road 2000",
           "fg home 2000", "fg diff 2000", "fg count 2000", nil, "fg road 1990", "fg home 1990", "fg diff 1990", "fg count 1990",
           "1h road 2000", "1h home 2000", "1h diff 2000", "1h  count 2000", nil, "1h road 1990", "1h home 1990", "1h diff 1990", 
           "1h  count 1990", "2h road 2000", "2h home 2000", "2h diff 2000", "2h count 2000", nil, "2h road 1990", "2h home 1990", 
           "2h diff 1990", "2h count 1990", nil, "fg total pt 2000", "fg total line 2000", "fg total diff 2000", "fg total count 2000", 
           "1h total pt 2000", "1h total line 2000", "1h total diff 2000", "1h total count 2000", "2h total pt 2000", "2h total line 2000", 
           "2h total diff 2000", "2h total count 2000", "fg pt 1990", "fg line 1990", "1h pt 1990", "1h line 1990", "2h pts 1990", 
           "2h line 1990", "bday yesterday", "yest home", "yest away", "bday today", "today home", "today away", "bday tomorrow", 
           "morrow home", "morrow away", "Away Player1", nil, "Away Player2", nil, "Away Player3", nil, "Away Player4", nil, "Away Player5",
           nil, "Away Player6", nil, "Away Player7", nil, "Away Player8", nil, "Home Player1", nil, "Home Player2", nil, "Home Player3", 
           nil, "Home Player4", nil, "Home Player5", nil, "Home Player6", nil, "Home Player7", nil, "Home Player8", nil],

          style:  [header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell,
                  header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell,
                  header_red_cell, header_cell_peach, header_cell_peach, header_red_cell, header_red_cell, header_red_cell, header_red_cell,
                  header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell,
                  header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell,
                  header_red_cell, header_cell_peach, header_cell_peach, header_red_cell, header_red_cell, header_red_cell, header_red_cell,
                  header_red_cell, header_red_cell, header_red_cell, header_red_cell,header_red_cell, header_red_cell, header_red_cell, header_color_mustard,
                  header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell,
                  header_red_cell, header_red_cell, header_color_green2, header_color_green2, header_color_green2, header_color_green2,
                  header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell,
                  header_color_skin, header_color_white, header_color_skin, header_red_cell, header_red_cell, header_red_cell,
                  header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_color_seagreen, header_color_seagreen,
                  header_color_lightpurple, header_color_seagreen, header_color_seagreen, header_color_lightpurple, header_color_seagreen,
                  header_color_seagreen, header_color_lightpurple, header_color_seagreen, header_color_seagreen,
                  header_color_lightpurple, header_color_green2, header_color_green2, header_color_lightgreen, header_color_green2,
                  header_color_green2, header_color_lightgreen, header_color_green2, header_color_green2, header_color_lightgreen,
                  header_color_green2, header_color_green2, header_color_lightgreen, header_color_orange, header_color_orange,
                  header_color_lightorange, header_color_orange, header_color_orange, header_color_lightorange, header_color_orange,
                  header_color_orange, header_color_lightorange, header_color_orange, header_color_orange, header_color_lightorange, 
                  header_color_lightpurple, header_color_lightpurple, header_color_lightpurple, header_color_lightpurple, header_color_lightpurple,
                  header_color_lightpurple, header_color_lightpurple, header_color_lightpurple, header_color_lightpurple, header_color_lightpurple,
                  header_color_lightpurple, header_color_lightpurple, header_color_skin,header_color_skin, header_color_skin, header_color_skin,
                  header_color_skin, header_color_skin, header_color_skin, header_color_skin, header_color_skin, header_color_skin,
                  header_color_skin, header_color_skin, header_cell_peach, header_cell_peach, header_cell_peach, header_cell_peach, header_cell_peach,
                  header_color_lightpurple, header_color_lightpurple, header_color_purple, header_color_lightpurple, header_color_lightpurple,
                  header_color_purple, header_red_cell, header_red_cell,header_red_cell, header_color_yellow, header_color_yellow,
                  header_color_yellow, header_color_darkblue, header_color_lightyellow, header_color_lightyellow, header_color_lightyellow,
                  header_red_cell, header_red_cell, header_red_cell,header_red_cell, header_red_cell, header_color_lightblue,
                  header_color_lightblue, header_color_lightblue, header_color_lightblue, header_color_black, header_color_lightblue, header_color_lightblue, header_color_lightblue, header_color_lightblue,
                  header_color_lightblue, header_color_lightblue, header_color_lightblue, header_color_lightblue, header_color_black, header_color_lightblue,
                  header_color_lightblue, header_color_lightblue, 
                  header_color_lightblue, header_color_lightblue, header_color_lightblue, header_color_lightblue, header_color_lightblue, header_color_black, header_color_lightblue, header_color_lightblue, 
                  header_color_lightblue, header_color_lightblue, header_color_black, header_color_skin, header_color_skin, header_color_skin, header_color_skin, 
                  header_cell_peach, header_cell_peach, header_cell_peach, header_cell_peach, header_color_skin, header_color_skin, 
                  header_color_skin, header_color_skin, header_color_greenlast, header_color_greenlast, header_color_greenlast, header_color_greenlast,header_color_greenlast, 
                  header_color_greenlast, header_color_mustard, header_color_skin, header_color_skin, header_color_mustard, header_color_skin, header_color_skin, header_color_mustard, 
                  header_color_skin, header_color_skin, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell,
                  header_red_cell, header_red_cell, header_red_cell,header_red_cell,
                  header_red_cell, header_red_cell, header_red_cell,header_red_cell, header_red_cell, header_red_cell, header_red_cell,
                  header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, 
                  header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell, header_red_cell,
                  header_red_cell, header_red_cell,header_red_cell, header_red_cell]
          #games = Nba.find([1,2])
          games = Nba.where("game_date between ? and ?", Date.strptime(game_start_date).beginning_of_day, Date.strptime(game_end_date).end_of_day)
          games.each do |game|
            puts "starting game #{game.game_id}"
            date = DateTime.parse(game.game_date)
            day_month = date.strftime('%d-%b')[0]=="0" ? date.strftime('%d-%b')[1..5] : date.strftime('%d-%b')

            away_first_second_quarter = (game.away_first_quarter.nil? ? 0 : game.away_first_quarter) + (game.away_second_quarter.nil? ? 0 : game.away_second_quarter)
            away_first_sec_third_quarter = (game.away_first_quarter.nil? ? 0 : game.away_first_quarter)+(game.away_second_quarter.nil? ? 0 : game.away_second_quarter)+(game.away_third_quarter.nil? ? 0 : game.away_third_quarter)
            away_third_forth_quarter = (game.away_third_quarter.nil? ? 0 : game.away_third_quarter)+(game.away_forth_quarter.nil? ? 0 : game.away_forth_quarter)
            home_first_second_quarter = (game.home_first_quarter.nil? ? 0 : game.home_first_quarter)+(game.home_second_quarter.nil? ? 0 : game.home_second_quarter)
            home_first_sec_third_quarter = (game.home_first_quarter.nil? ? 0 : game.home_first_quarter)+(game.home_second_quarter.nil? ? 0 : game.home_second_quarter)+(game.home_third_quarter.nil? ? 0 : game.home_third_quarter)
            home_third_forth_quarter = (game.home_third_quarter.nil? ? 0 : game.home_third_quarter)+(game.home_forth_quarter.nil? ? 0 : game.home_forth_quarter)
            away_home_score = (game.away_score.nil? ? 0 : game.away_score)+(game.home_score.nil? ? 0 : game.home_score)
            away_last_next_home = (game.away_last_home.nil? ? 0 : game.away_last_home)+(game.away_next_home.nil? ? 0 : game.away_next_home)
            home_last_next_away = (game.home_last_away.nil? ? 0 : game.home_last_away)+(game.home_next_away.nil? ? 0 : game.home_next_away)
            first_half_home_or_away = (game.first_closer_side.nil? ? 0 : game.first_closer_side) + home_first_second_quarter > away_first_second_quarter ? 'HOME' : 'AWAY'
            second_half_home_or_away = (game.second_closer_side.nil? ? 0 : game.second_closer_side) + home_third_forth_quarter > away_third_forth_quarter ? 'HOME' : 'AWAY'
            fullgame_home_or_away = (game.full_closer_side.nil? ? 0 : game.full_closer_side) + (game.home_score.nil? ? 0 : game.home_score) > (game.away_score.nil? ? 0 : game.away_score) ? 'HOME' : 'AWAY'
            first_half_under_over = (game.first_point.nil? ? 0 : game.first_point) > (game.first_closer_total.nil? ? 0 : game.first_closer_total) ? 'over' : 'under'
            second_half_under_over = (game.second_point.nil? ? 0 : game.second_point) > (game.second_closer_total.nil? ? 0 : game.second_closer_total) ? 'over' : 'under'
            total_point_under_over = (game.total_point.nil? ? 0 : game.total_point) > (game.full_closer_total.nil? ? 0 : game.full_closer_total) ? 'over' : 'under'

            sheet.add_row ['',date.strftime('%Y'),date.strftime('%b %d'),convert_timezone(date,game.home_timezone),date.strftime('%a'),game.tv_station.nil? ? '' : game.tv_station.split(",")[0],
            game.tv_station.nil? ? '' : game.tv_station.split(",")[1],game.game_count,game.away_last_fly,game.away_last_game,game.away_next_game,
            game.away_next_fly,game.away_team,'','',game.away_team_city,game.away_team_next_city,game.away_ppg_rank,
            game.away_oppppg_rank,game.away_timezone,game.home_timezone,game.away_first_quarter,game.away_second_quarter,away_first_second_quarter,
            game.away_third_quarter,away_first_sec_third_quarter,game.away_forth_quarter,
            game.away_ot_quarter,away_third_forth_quarter,game.home_next_game,game.home_next_fly,game.home_last_game,game.home_last_fly,game.home_team,
            game.home_win_rank,'',game.home_team_city,game.home_team_next_city,game.home_ppg_rank,game.home_oppppg_rank,game.home_timezone,
            game.home_first_quarter,game.home_second_quarter,home_first_second_quarter,game.home_third_quarter,
            home_first_sec_third_quarter,game.home_forth_quarter,home_third_forth_quarter,game.home_ot_quarter,
            '','','','','',game.away_score,game.home_score,away_home_score,game.first_point,game.second_point,
            '','','','',game.total_point,first_half_under_over, second_half_under_over,
            total_point_under_over,
            game.first_closer_total,game.second_closer_total,game.full_closer_total,first_half_home_or_away,
            second_half_home_or_away,fullgame_home_or_away,game.first_closer_side,game.second_closer_side,'',game.full_closer_side,
            game.home_last_ot,game.away_last_ot,'','','','','','','','','','','','','','','','','','','','','','','','','','','','',
            '','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',
            game.pace,game.away_ortg,game.home_ortg,game.away_last_home,game.away_next_home,away_last_next_home,
            '',game.home_last_away,game.home_next_away,home_last_next_away,'','','','','',game.fg_road_2000,game.fg_home_2000,
            game.fg_diff_2000,game.fg_count_2000,'',game.fg_road_1990,game.fg_home_1990,game.fg_diff_1990,game.fg_count_1990,game.first_half_road_2000,
            game.first_half_home_2000,game.first_half_diff_2000,game.first_half_count_2000,'',game.first_half_road_1990,game.first_half_home_1990,
            game.first_half_diff_1990,game.first_half_count_1990,game.second_half_road_2000,game.second_half_home_2000,game.second_half_diff_2000,
            game.second_half_count_2000,'',game.second_half_road_1990,game.second_half_home_1990,game.second_half_diff_1990,game.second_half_count_1990,
            '',game.fg_total_pt_2000,game.fg_total_line_2000,game.fg_total_diff_2000,game.fg_total_count_2000,game.first_half_total_pt_2000,
            game.first_half_total_line_2000,game.first_half_total_diff_2000,game.first_half_total_count_2000,game.second_half_total_pt_2000,
            game.second_half_total_line_2000,game.second_half_total_diff_2000,game.second_half_total_count_2000,game.fg_total_pt_1990,game.fg_total_line_1990,
            game.first_half_total_pt_1990,game.first_half_total_line_1990,game.second_half_total_pt_1990,game.second_half_total_line_1990,
            '','','','','','','','','',game.away_player1_name,game.away_player1_birthday.nil? ? '' : game.away_player1_birthday[0..11],
            game.away_player2_name,game.away_player2_birthday.nil? ? '' : game.away_player2_birthday[0..11],
            game.away_player3_name,game.away_player3_birthday.nil? ? '' : game.away_player3_birthday[0..11],
            game.away_player4_name,game.away_player4_birthday.nil? ? '' : game.away_player4_birthday[0..11],
            game.away_player5_name,game.away_player5_birthday.nil? ? '' : game.away_player5_birthday[0..11],
            game.away_player6_name,game.away_player6_birthday.nil? ? '' : game.away_player6_birthday[0..11],
            game.away_player7_name,game.away_player7_birthday.nil? ? '' : game.away_player7_birthday[0..11],
            game.away_player8_name,game.away_player8_birthday.nil? ? '' : game.away_player8_birthday[0..11],
            game.home_player1_name,game.home_player1_birthday.nil? ? '' : game.home_player1_birthday[0..11],
            game.home_player2_name,game.home_player2_birthday.nil? ? '' : game.home_player2_birthday[0..11],
            game.home_player3_name,game.home_player3_birthday.nil? ? '' : game.home_player3_birthday[0..11],
            game.home_player4_name,game.home_player4_birthday.nil? ? '' : game.home_player4_birthday[0..11],
            game.home_player5_name,game.home_player5_birthday.nil? ? '' : game.home_player5_birthday[0..11],
            game.home_player6_name,game.home_player6_birthday.nil? ? '' : game.home_player6_birthday[0..11],
            game.home_player7_name,game.home_player7_birthday.nil? ? '' : game.home_player7_birthday[0..11],
            game.home_player8_name,game.home_player8_birthday.nil? ? '' : game.home_player8_birthday[0..11]

          ],

          style:  [header_color_white, header_color_white, header_color_white, header_color_white, header_color_white, header_color_white, header_color_white,
                  header_color_white, header_color_lightskin, header_color_darkorange, header_color_skyblue, header_color_lightskin, header_color_white, header_red_cell,
                  header_color_darkred, header_cell_peach, header_cell_peach, header_color_yellow, header_color_greenlast,
                  header_color_white, header_color_white, header_color_white, header_color_white, header_color_lightskin, header_color_white, header_color_lightskin, header_color_white, header_color_white,
                  header_color_lightskin, header_color_skyblue, header_color_lightskin, header_color_darkorange, header_color_lightskin, header_color_white, header_red_cell,
                  header_color_darkred, header_cell_peach, header_cell_peach, header_color_yellow, header_color_greenlast, header_color_white, header_color_white,
                  header_color_white, header_color_lightskin, header_color_white, header_color_lightskin,header_color_white, header_color_lightskin, header_color_white, header_color_mustard,
                  header_color_white, header_color_white, header_color_white, header_color_white, header_color_lightskin, header_color_lightskin, header_color_white,
                  header_color_mildblue, header_color_skyblue, header_color_green2, header_color_green2, header_color_green2, header_color_green2,
                  header_red_cell, header_color_lightskin, header_color_lightskin, header_color_lightskin, header_color_white, header_color_white, header_color_white,
                  header_color_skin, header_color_skin, header_color_skin, header_color_white, header_color_white, header_color_darkred,
                  header_red_cell, header_color_white, header_color_white, header_color_white, header_color_white, header_color_white,
                  header_color_white, header_color_white, header_color_white, header_color_white, header_color_white,
                  header_color_white, header_color_white, header_color_white, header_color_white,
                  header_color_white, header_color_white, header_color_white, header_color_white, header_color_white,
                  header_color_white, header_color_white, header_color_white, header_color_white, header_color_white,
                  header_color_white, header_color_white, header_color_white, header_color_white, header_color_white,
                  header_color_white, header_color_white, header_color_white, header_color_white, header_color_white,
                  header_color_white, header_color_white, header_color_white, header_color_white, header_color_white, 
                  header_color_lightpurple, header_color_lightpurple, header_color_lightpurple, header_color_lightpurple, header_color_lightpurple,
                  header_color_lightpurple, header_color_lightpurple, header_color_lightpurple, header_color_lightpurple, header_color_lightpurple,
                  header_color_lightpurple, header_color_lightpurple, header_color_skin,header_color_skin, header_color_skin, header_color_skin,
                  header_color_skin, header_color_skin, header_color_skin, header_color_skin, header_color_skin, header_color_skin,
                  header_color_skin, header_color_skin, header_cell_peach, header_cell_peach, header_cell_peach, header_cell_peach, header_cell_peach,
                  header_color_lightpurple, header_color_lightpurple, header_color_purple, header_color_lightpurple, header_color_lightpurple,
                  header_color_purple, header_color_white, header_color_lightskin,header_color_skin, header_color_yellow, header_color_yellow,
                  header_color_yellow, header_color_darkblue, header_color_lightyellow, header_color_lightyellow, header_color_lightyellow,
                  header_color_white, header_color_white, header_red_cell,header_cell_peach, header_color_lightpurple, header_color_lightblue,
                  header_color_lightblue, header_color_lightblue, header_color_lightblue, header_color_black, header_color_lightblue, header_color_lightblue, header_color_lightblue, header_color_lightblue,
                  header_color_lightskin, header_color_lightskin, header_color_lightskin, header_color_lightskin, header_color_black, header_color_lightskin,
                  header_color_lightskin, header_color_lightskin, 
                  header_color_lightskin, header_color_lightgreen, header_color_lightgreen, header_color_lightgreen, header_color_lightgreen, header_color_black, header_color_lightgreen, header_color_lightgreen, 
                  header_color_lightgreen, header_color_lightgreen, header_color_black, header_red_cell, header_red_cell, header_red_cell, header_red_cell,
                  header_cell_peach, header_cell_peach, header_cell_peach, header_cell_peach, header_red_cell, header_red_cell, 
                  header_red_cell, header_red_cell, header_color_greenlast, header_color_greenlast, header_color_greenlast, header_color_greenlast,header_color_greenlast, 
                  header_color_greenlast, header_color_mustard, header_color_skin, header_color_skin, header_color_mustard, header_color_skin, header_color_skin, header_color_mustard, 
                  header_color_skin, header_color_skin,
                  header_color_white, header_color_white, header_color_white, header_color_white, header_color_white,
                  header_color_white, header_color_white, header_color_white,header_color_white,
                  header_color_white, header_color_white, header_color_white,header_color_white, header_color_white, header_color_white, header_color_white,
                  header_color_white, header_color_white, header_color_white, header_color_white, header_color_white, 
                  header_color_white, header_color_white, header_color_white, header_color_white, header_color_white, header_color_white, header_color_white,
                  header_color_white, header_color_white,header_color_white, header_color_white]
          puts "ending game #{game.game_id}"
          end
      end
      package.serialize(data_file_path)
      obj = S3.object("nba_data/nba_data_sheet_2018_to_2020.xlsx")
      obj.upload_file(data_file_path, acl:'public-read')
      return obj.public_url
=begin    
    book = Spreadsheet::Workbook.new 
   	book = Spreadsheet.open(data_file_path)

    sheet1 = book.create_worksheet :name => "MAIN (6)"
   		header = [nil, "Year", "Date", "Time", "Week", "tv2", "tv", "count", "is last game home", "last", "next", "is next game home",
   			   "Away Team", "away_win_rank", true, "last city", "next city", "away_ppg_rank", "away_oppppg_rank", "FROM", "TO", "1Q", "2Q",
   			   nil, "3Q", nil, "4Q", "OT", nil, "next", "FLY", "last", "FLY", "Home Team", "home_win_rank", nil, "last city", "next city",
   			   "home_ppg_rank", "home_oppppg_rank", "Timezone", "1Q", "2Q", nil, "3Q", nil, "4Q", nil, "OT", "lead @ HALF", "3RD Q lead",
   			   "final", "TRUE 2H PTS", "4TH Q", "road", "home", "total", "1H Point", "2H Point", "1q", "2q", "3q", "4q", "Total Point",
   			   "1h", "2h", "f", "1H Line Total", "2H Line Total", "FG Line Total", "1H", "2h", "fg", "1H Side", "2H Side", "XXX",
   			   "FG Side", "did home team play over time last game", "did road team play over time last game", "PtsPerPoss",
   			   "last 1h away under", "last 1h away over", " last 1h away %", "last 1h home under", "last 1h home over",
   			   "last 1h home %", "next 1h away under", "next 1h away over", "next 1h away %", "next 1h home under", "next 1h home over",
   			   "next 1h home %", "last 2h away under", "last 2h away over", " last 2h away %", "last 2h home under", "last 2h home over",
   			   "last 2h home %", "next 2h away under", "next 2h away over", "next 2h away %", "next 2h home under", "next 2h home over",
   			   "next 2h home %", "last fg away under", "last fg away over", " last fg away %", "last fg home under", "last fg home over",
   			   "last fg home %", "next fg away under", "next fg away over", "next fg away %", "next fg home under", "next fg home over",
   			   "next fg home %", "1hawayFGA", "1hawayFG", "1hawayFG %", "1hawayFTA", "1haway3PA", "1haway3P", "1haway3P %",
   			   "1haway OR's", "1hawaySTEALS", "1hawayBLOCKS", "1haway TO's", "OR+BL+STl-TO", "1hhomeFGA", "1hhomeFG",
   			   "1hhomeFG %", "1hhomeFTA", "1hhome3PA", "1hhome3P", "1hhome3P %", "1hhome OR's", "1hhomeSTEALS", "1hhomeBLOCKS",
   			   "1hhome TO's", "OR+BL+STl-TO", "FG% diff", "3P% diff", "OR diff", "TO diff", "CE-CQ", "1h home possession",
   			   "1h road possession", "1h total possession", "2h home possession", "2h road possession", "2h total possession",
   			   "pace", "away_ortg", "home_ortg", "away_last_home", "away_next_home", "DM  + DN", nil, "home teams last road game",
   			   "home teams next road game", "DQ+DR", 99.09, 97.01, "1h points", "2h points", "total points", "fg road 2000",
   			   "fg home 2000", "fg diff 2000", "fg count 2000", nil, "fg road 1990", "fg home 1990", "fg diff 1990", "fg count 1990",
   			   "1h road 2000", "1h home 2000", "1h diff 2000", "1h  count 2000", nil, "1h road 1990", "1h home 1990", "1h diff 1990", 
   			   "1h  count 1990", "2h road 2000", "2h home 2000", "2h diff 2000", "2h count 2000", nil, "2h road 1990", "2h home 1990", 
   			   "2h diff 1990", "2h count 1990", nil, "fg total pt 2000", "fg total line 2000", "fg total diff 2000", "fg total count 2000", 
   			   "1h total pt 2000", "1h total line 2000", "1h total diff 2000", "1h total count 2000", "2h total pt 2000", "2h total line 2000", 
   			   "2h total diff 2000", "2h total count 2000", "fg pt 1990", "fg line 1990", "1h pt 1990", "1h line 1990", "2h pts 1990", 
   			   "2h line 1990", "bday yesterday", "yest home", "yest away", "bday today", "today home", "today away", "bday tomorrow", 
   			   "morrow home", "morrow away", "Away Player1", nil, "Away Player2", nil, "Away Player3", nil, "Away Player4", nil, "Away Player5",
   			   nil, "Away Player6", nil, "Away Player7", nil, "Away Player8", nil, "Home Player1", nil, "Home Player2", nil, "Home Player3", 
   			   nil, "Home Player4", nil, "Home Player5", nil, "Home Player6", nil, "Home Player7", nil, "Home Player8", nil]
   			

   		sheet1.insert_row(0, header)
   		
      games = Nba.find([1,2])
		  #games = Nba.where("game_date between ? and ?", Date.strptime(game_start_date).beginning_of_day, Date.strptime(game_end_date).end_of_day)   		
   		games.each_with_index  { |game, i| 
   		date = DateTime.parse(game.game_date)
      day_month = date.strftime('%d-%b')[0]=="0" ? date.strftime('%d-%b')[1..5] : date.strftime('%d-%b')
      full_season_data = Fullseason.where(roadteam: game.away_team, hometeam: game.home_team, year: date.strftime('%Y'),date: day_month,time: date.strftime('%I:%M %p'))
      first_ou = full_season_data.empty? ? '' : full_season_data.firstou
      second_ou = full_season_data.empty? ? '' : full_season_data.secondou
      total_ou = full_season_data.empty? ? '' : full_season_data.totalou 

      away_first_second_quarter = (game.away_first_quarter.nil? ? 0 : game.away_first_quarter) + (game.away_second_quarter.nil? ? 0 : game.away_second_quarter)
      away_first_sec_third_quarter = (game.away_first_quarter.nil? ? 0 : game.away_first_quarter)+(game.away_second_quarter.nil? ? 0 : game.away_second_quarter)+(game.away_third_quarter.nil? ? 0 : game.away_third_quarter)
      home_first_second_quarter = (game.home_first_quarter.nil? ? 0 : game.home_first_quarter)+(game.home_second_quarter.nil? ? 0 : game.home_second_quarter)
      home_first_sec_third_quarter = (game.home_first_quarter.nil? ? 0 : game.home_first_quarter)+(game.home_second_quarter.nil? ? 0 : game.home_second_quarter)+(game.home_third_quarter.nil? ? 0 : game.home_third_quarter)
      away_home_score = (game.away_score.nil? ? 0 : game.away_score)+(game.home_score.nil? ? 0 : game.home_score)
      away_last_next_home = (game.away_last_home.nil? ? 0 : game.away_last_home)+(game.away_next_home.nil? ? 0 : game.away_next_home)
     	home_last_next_away = (game.home_last_away.nil? ? 0 : game.home_last_away)+(game.home_next_away.nil? ? 0 : game.home_next_away)

      sheet1.row(i+1).replace ['',date.strftime('%Y'),date.strftime('%b %d'),date.strftime('%I:%M %p'),date.strftime('%a'),game.tv_station.nil? ? '' : game.tv_station.split(",")[0],
     				game.tv_station.nil? ? '' : game.tv_station.split(",")[1],game.game_count,game.away_last_fly,game.away_last_game,game.away_next_game,
     				game.away_next_fly,game.away_team,game.away_win_rank,'',game.away_team_city,game.away_team_next_city,game.away_ppg_rank,
     				game.away_oppppg_rank,game.away_timezone,game.home_timezone,game.away_first_quarter,game.away_second_quarter,away_first_second_quarter,
     				game.away_third_quarter,away_first_sec_third_quarter,game.away_forth_quarter,
     				game.away_ot_quarter,'',game.home_next_game,game.home_next_fly,game.home_last_game,game.home_last_fly,game.home_team,
     				game.home_win_rank,'',game.home_team_city,game.home_team_next_city,game.home_ppg_rank,game.home_oppppg_rank,game.home_timezone,
     				game.home_first_quarter,game.home_second_quarter,home_first_second_quarter,game.home_third_quarter,
     				home_first_sec_third_quarter,game.home_forth_quarter,'',game.home_ot_quarter,
     				'','','','','',game.away_score,game.home_score,away_home_score,game.first_point,game.second_point,
     				'','','','',game.total_point,first_ou,second_ou,total_ou,
            game.first_closer_total,game.second_closer_total,game.full_closer_total,game.first_half_bigger,
     				game.second_half_bigger,game.fullgame_bigger,game.first_closer_side,game.second_closer_side,'',game.full_closer_side,
     				game.home_last_ot,game.away_last_ot,'','','','','','','','','','','','','','','','','','','','','','','','','','','','',
     				'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',
     				game.pace,game.away_ortg,game.home_ortg,game.away_last_home,game.away_next_home,away_last_next_home,
     				'',game.home_last_away,game.home_next_away,home_last_next_away,'','','','','',game.fg_road_2000,game.fg_home_2000,
     				game.fg_diff_2000,game.fg_count_2000,'',game.fg_road_1990,game.fg_home_1990,game.fg_diff_1990,game.fg_count_1990,game.first_half_road_2000,
     				game.first_half_home_2000,game.first_half_diff_2000,game.first_half_count_2000,'',game.first_half_road_1990,game.first_half_home_1990,
     				game.first_half_diff_1990,game.first_half_count_1990,game.second_half_road_2000,game.second_half_home_2000,game.second_half_diff_2000,
     				game.second_half_count_2000,'',game.second_half_road_1990,game.second_half_home_1990,game.second_half_diff_1990,game.second_half_count_1990,
     				'',game.fg_total_pt_2000,game.fg_total_line_2000,game.fg_total_diff_2000,game.fg_total_count_2000,game.first_half_total_pt_2000,
     				game.first_half_total_line_2000,game.first_half_total_diff_2000,game.first_half_total_count_2000,game.second_half_total_pt_2000,
     				game.second_half_total_line_2000,game.second_half_total_diff_2000,game.second_half_total_count_2000,game.fg_total_pt_1990,game.fg_total_line_1990,
     				game.first_half_total_pt_1990,game.first_half_total_line_1990,game.second_half_total_pt_1990,game.second_half_total_line_1990,
     				'','','','','','','','','',game.away_player1_name,game.away_player1_birthday.nil? ? '' : game.away_player1_birthday[0..11],
            game.away_player2_name,game.away_player2_birthday.nil? ? '' : game.away_player2_birthday[0..11],
     				game.away_player3_name,game.away_player3_birthday.nil? ? '' : game.away_player3_birthday[0..11],
            game.away_player4_name,game.away_player4_birthday.nil? ? '' : game.away_player4_birthday[0..11],
     				game.away_player5_name,game.away_player5_birthday.nil? ? '' : game.away_player5_birthday[0..11],
            game.away_player6_name,game.away_player6_birthday.nil? ? '' : game.away_player6_birthday[0..11],
     				game.away_player7_name,game.away_player7_birthday.nil? ? '' : game.away_player7_birthday[0..11],
            game.away_player8_name,game.away_player8_birthday.nil? ? '' : game.away_player8_birthday[0..11],
     				game.home_player1_name,game.home_player1_birthday.nil? ? '' : game.home_player1_birthday[0..11],
            game.home_player2_name,game.home_player2_birthday.nil? ? '' : game.home_player2_birthday[0..11],
     				game.home_player3_name,game.home_player3_birthday.nil? ? '' : game.home_player3_birthday[0..11],
            game.home_player4_name,game.home_player4_birthday.nil? ? '' : game.home_player4_birthday[0..11],
     				game.home_player5_name,game.home_player5_birthday.nil? ? '' : game.home_player5_birthday[0..11],
            game.home_player6_name,game.home_player6_birthday.nil? ? '' : game.home_player6_birthday[0..11],
     				game.home_player7_name,game.home_player7_birthday.nil? ? '' : game.home_player7_birthday[0..11],
            game.home_player8_name,game.home_player8_birthday.nil? ? '' : game.home_player8_birthday[0..11]

     			]
   		} 
       
      File.delete(data_file_path)
   		#export_file_path = [Rails.root, "public", "exports", "nba_databases_data.xls"].join("/")
   		book.write data_file_path
      #obj = S3.object("nba_data/nba_data_sheet.xls")
      #obj.upload_file(export_file_path, acl:'public-read')
      #return obj.public_url
=end	
  end

  def self.convert_timezone(date_time,timezone)
    timezones = ["PACIFIC","CENTRAL","MOUNTAIN"]
    if timezones.include? timezone
      if timezone == "PACIFIC"
        date = (date_time - 3.hours).to_datetime
      elsif timezone == "CENTRAL"
        date = (date_time - 1.hours).to_datetime
      elsif timezone == "MOUNTAIN"
        date = (date_time - 2.hours).to_datetime
      end 
      return date.strftime('%I:%M %p')     
    else
      return date_time.strftime('%I:%M %p')
    end
  end

  def self.update_sheet_in_data_file(start_date,end_date)
    data_file_path = [Rails.root, "csv", "nba_bday_12.27_feb26_2.xlsx"].join("/")
    workbook = RubyXL::Parser.parse(data_file_path)
    puts "read file"
    worksheet = workbook.add_worksheet('MAIN (6)')
    puts "sheet added"
    header = [nil, "Year", "Date", "Time", "Week", "tv2", "tv", "count", "is last game home", "last", "next", "is next game home",
           "Away Team", "away_win_rank", true, "last city", "next city", "away_ppg_rank", "away_oppppg_rank", "FROM", "TO", "1Q", "2Q",
           "1h total", "3Q", nil, "4Q", "OT", nil, "next", "FLY", "last", "FLY", "Home Team", "home_win_rank", nil, "last city", "next city",
           "home_ppg_rank", "home_oppppg_rank", "Timezone", "1Q", "2Q", nil, "3Q", nil, "4Q", nil, "OT", "lead @ HALF", "3RD Q lead",
           "final", "TRUE 2H PTS", "4TH Q", "road", "home", "total", "1H Point", "2H Point", "1q", "2q", "3q", "4q", "Total Point",
           "1h", "2h", "f", "1H Line Total", "2H Line Total", "FG Line Total", "1H", "2h", "fg", "1H Side", "2H Side", "XXX",
           "FG Side", "did home team play over time last game", "did road team play over time last game", "PtsPerPoss",
           "last 1h away under", "last 1h away over", " last 1h away %", "last 1h home under", "last 1h home over",
           "last 1h home %", "next 1h away under", "next 1h away over", "next 1h away %", "next 1h home under", "next 1h home over",
           "next 1h home %", "last 2h away under", "last 2h away over", " last 2h away %", "last 2h home under", "last 2h home over",
           "last 2h home %", "next 2h away under", "next 2h away over", "next 2h away %", "next 2h home under", "next 2h home over",
           "next 2h home %", "last fg away under", "last fg away over", " last fg away %", "last fg home under", "last fg home over",
           "last fg home %", "next fg away under", "next fg away over", "next fg away %", "next fg home under", "next fg home over",
           "next fg home %", "1hawayFGA", "1hawayFG", "1hawayFG %", "1hawayFTA", "1haway3PA", "1haway3P", "1haway3P %",
           "1haway OR's", "1hawaySTEALS", "1hawayBLOCKS", "1haway TO's", "OR+BL+STl-TO", "1hhomeFGA", "1hhomeFG",
           "1hhomeFG %", "1hhomeFTA", "1hhome3PA", "1hhome3P", "1hhome3P %", "1hhome OR's", "1hhomeSTEALS", "1hhomeBLOCKS",
           "1hhome TO's", "OR+BL+STl-TO", "FG% diff", "3P% diff", "OR diff", "TO diff", "CE-CQ", "1h home possession",
           "1h road possession", "1h total possession", "2h home possession", "2h road possession", "2h total possession",
           "pace", "away_ortg", "home_ortg", "away_last_home", "away_next_home", "DM  + DN", nil, "home teams last road game",
           "home teams next road game", "DQ+DR", 99.09, 97.01, "1h points", "2h points", "total points", "fg road 2000",
           "fg home 2000", "fg diff 2000", "fg count 2000", nil, "fg road 1990", "fg home 1990", "fg diff 1990", "fg count 1990",
           "1h road 2000", "1h home 2000", "1h diff 2000", "1h  count 2000", nil, "1h road 1990", "1h home 1990", "1h diff 1990", 
           "1h  count 1990", "2h road 2000", "2h home 2000", "2h diff 2000", "2h count 2000", nil, "2h road 1990", "2h home 1990", 
           "2h diff 1990", "2h count 1990", nil, "fg total pt 2000", "fg total line 2000", "fg total diff 2000", "fg total count 2000", 
           "1h total pt 2000", "1h total line 2000", "1h total diff 2000", "1h total count 2000", "2h total pt 2000", "2h total line 2000", 
           "2h total diff 2000", "2h total count 2000", "fg pt 1990", "fg line 1990", "1h pt 1990", "1h line 1990", "2h pts 1990", 
           "2h line 1990", "bday yesterday", "yest home", "yest away", "bday today", "today home", "today away", "bday tomorrow", 
           "morrow home", "morrow away", "Away Player1", nil, "Away Player2", nil, "Away Player3", nil, "Away Player4", nil, "Away Player5",
           nil, "Away Player6", nil, "Away Player7", nil, "Away Player8", nil, "Home Player1", nil, "Home Player2", nil, "Home Player3", 
           nil, "Home Player4", nil, "Home Player5", nil, "Home Player6", nil, "Home Player7", nil, "Home Player8", nil]
      for indx in 0...253
        worksheet.add_cell(0, indx, header[indx])
      end 
      puts "header added"
      games = Nba.where("game_date between ? and ?", Date.strptime(start_date).beginning_of_day, Date.strptime(end_date).end_of_day)      
      game_row_index = 1
      games.each do |game|
        date = DateTime.parse(game.game_date)
        day_month = date.strftime('%d-%b')[0]=="0" ? date.strftime('%d-%b')[1..5] : date.strftime('%d-%b')
        full_season_data = Fullseason.where(roadteam: game.away_team, hometeam: game.home_team, year: date.strftime('%Y'),date: day_month,time: date.strftime('%I:%M %p'))
        first_ou = full_season_data.empty? ? '' : full_season_data.firstou
        second_ou = full_season_data.empty? ? '' : full_season_data.secondou
        total_ou = full_season_data.empty? ? '' : full_season_data.totalou 

        away_first_second_quarter = (game.away_first_quarter.nil? ? 0 : game.away_first_quarter) + (game.away_second_quarter.nil? ? 0 : game.away_second_quarter)
        away_first_sec_third_quarter = (game.away_first_quarter.nil? ? 0 : game.away_first_quarter)+(game.away_second_quarter.nil? ? 0 : game.away_second_quarter)+(game.away_third_quarter.nil? ? 0 : game.away_third_quarter)
        home_first_second_quarter = (game.home_first_quarter.nil? ? 0 : game.home_first_quarter)+(game.home_second_quarter.nil? ? 0 : game.home_second_quarter)
        home_first_sec_third_quarter = (game.home_first_quarter.nil? ? 0 : game.home_first_quarter)+(game.home_second_quarter.nil? ? 0 : game.home_second_quarter)+(game.home_third_quarter.nil? ? 0 : game.home_third_quarter)
        away_home_score = (game.away_score.nil? ? 0 : game.away_score)+(game.home_score.nil? ? 0 : game.home_score)
        away_last_next_home = (game.away_last_home.nil? ? 0 : game.away_last_home)+(game.away_next_home.nil? ? 0 : game.away_next_home)
        home_last_next_away = (game.home_last_away.nil? ? 0 : game.home_last_away)+(game.home_next_away.nil? ? 0 : game.home_next_away)
      
        game_data_array = ['',date.strftime('%Y'),date.strftime('%b %d'),date.strftime('%I:%M %p'),date.strftime('%a'),game.tv_station.nil? ? '' : game.tv_station.split(",")[0],
            game.tv_station.nil? ? '' : game.tv_station.split(",")[1],game.game_count,game.away_last_fly,game.away_last_game,game.away_next_game,
            game.away_next_fly,game.away_team,game.away_win_rank,'',game.away_team_city,game.away_team_next_city,game.away_ppg_rank,
            game.away_oppppg_rank,game.away_timezone,game.home_timezone,game.away_first_quarter,game.away_second_quarter,away_first_second_quarter,
            game.away_third_quarter,away_first_sec_third_quarter,game.away_forth_quarter,
            game.away_ot_quarter,'',game.home_next_game,game.home_next_fly,game.home_last_game,game.home_last_fly,game.home_team,
            game.home_win_rank,'',game.home_team_city,game.home_team_next_city,game.home_ppg_rank,game.home_oppppg_rank,game.home_timezone,
            game.home_first_quarter,game.home_second_quarter,home_first_second_quarter,game.home_third_quarter,
            home_first_sec_third_quarter,game.home_forth_quarter,'',game.home_ot_quarter,
            '','','','','',game.away_score,game.home_score,away_home_score,game.first_point,game.second_point,
            '','','','',game.total_point,first_ou,second_ou,total_ou,
            game.first_closer_total,game.second_closer_total,game.full_closer_total,game.first_half_bigger,
            game.second_half_bigger,game.fullgame_bigger,game.first_closer_side,game.second_closer_side,'',game.full_closer_side,
            game.home_last_ot,game.away_last_ot,'','','','','','','','','','','','','','','','','','','','','','','','','','','','',
            '','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',
            game.pace,game.away_ortg,game.home_ortg,game.away_last_home,game.away_next_home,away_last_next_home,
            '',game.home_last_away,game.home_next_away,home_last_next_away,'','','','','',game.fg_road_2000,game.fg_home_2000,
            game.fg_diff_2000,game.fg_count_2000,'',game.fg_road_1990,game.fg_home_1990,game.fg_diff_1990,game.fg_count_1990,game.first_half_road_2000,
            game.first_half_home_2000,game.first_half_diff_2000,game.first_half_count_2000,'',game.first_half_road_1990,game.first_half_home_1990,
            game.first_half_diff_1990,game.first_half_count_1990,game.second_half_road_2000,game.second_half_home_2000,game.second_half_diff_2000,
            game.second_half_count_2000,'',game.second_half_road_1990,game.second_half_home_1990,game.second_half_diff_1990,game.second_half_count_1990,
            '',game.fg_total_pt_2000,game.fg_total_line_2000,game.fg_total_diff_2000,game.fg_total_count_2000,game.first_half_total_pt_2000,
            game.first_half_total_line_2000,game.first_half_total_diff_2000,game.first_half_total_count_2000,game.second_half_total_pt_2000,
            game.second_half_total_line_2000,game.second_half_total_diff_2000,game.second_half_total_count_2000,game.fg_total_pt_1990,game.fg_total_line_1990,
            game.first_half_total_pt_1990,game.first_half_total_line_1990,game.second_half_total_pt_1990,game.second_half_total_line_1990,
            '','','','','','','','','',game.away_player1_name,game.away_player1_birthday.nil? ? '' : game.away_player1_birthday[0..11],
            game.away_player2_name,game.away_player2_birthday.nil? ? '' : game.away_player2_birthday[0..11],
            game.away_player3_name,game.away_player3_birthday.nil? ? '' : game.away_player3_birthday[0..11],
            game.away_player4_name,game.away_player4_birthday.nil? ? '' : game.away_player4_birthday[0..11],
            game.away_player5_name,game.away_player5_birthday.nil? ? '' : game.away_player5_birthday[0..11],
            game.away_player6_name,game.away_player6_birthday.nil? ? '' : game.away_player6_birthday[0..11],
            game.away_player7_name,game.away_player7_birthday.nil? ? '' : game.away_player7_birthday[0..11],
            game.away_player8_name,game.away_player8_birthday.nil? ? '' : game.away_player8_birthday[0..11],
            game.home_player1_name,game.home_player1_birthday.nil? ? '' : game.home_player1_birthday[0..11],
            game.home_player2_name,game.home_player2_birthday.nil? ? '' : game.home_player2_birthday[0..11],
            game.home_player3_name,game.home_player3_birthday.nil? ? '' : game.home_player3_birthday[0..11],
            game.home_player4_name,game.home_player4_birthday.nil? ? '' : game.home_player4_birthday[0..11],
            game.home_player5_name,game.home_player5_birthday.nil? ? '' : game.home_player5_birthday[0..11],
            game.home_player6_name,game.home_player6_birthday.nil? ? '' : game.home_player6_birthday[0..11],
            game.home_player7_name,game.home_player7_birthday.nil? ? '' : game.home_player7_birthday[0..11],
            game.home_player8_name,game.home_player8_birthday.nil? ? '' : game.home_player8_birthday[0..11]
          ]

            for col in 0...253
              worksheet.add_cell(game_row_index, col, game_data_array[col])
            end
            puts "game #{game_row_index} added"
            game_row_index = game_row_index + 1
      end
      workbook.write(data_file_path)
      puts "file updated"
      obj = S3.object("nba_data/nba_data_sheet_all.xlsx")
      obj.upload_file(data_file_path, acl:'public-read')
      return obj.public_url
  end

  def self.update_sheet_last_week_data
    nba_data_file_path = [Rails.root, "public", "exports", "nba_databases_data.xls"].join("/")
    book = Spreadsheet.open(nba_data_file_path)
    sheet1 = book.worksheet(0)
    game_start_date = (Date.today - 7.days).to_s
    game_end_index = (Date.today).to_s
    games = Nba.where("game_date between ? and ?", Date.strptime(game_start_date).beginning_of_day, Date.strptime(game_end_date).end_of_day)      
    sheet_row = sheet1.last_row_index + 1
    games.each do |game|
      row_to_insert = ['',date.strftime('%Y'),date.strftime('%b %d'),date.strftime('%I:%M %p'),date.strftime('%a'),game.tv_station.nil? ? '' : game.tv_station.split(",")[0],
            game.tv_station.nil? ? '' : game.tv_station.split(",")[1],game.game_count,game.away_last_fly,game.away_last_game,game.away_next_game,
            game.away_next_fly,game.away_team,game.away_win_rank,'',game.away_team_city,game.away_team_next_city,game.away_ppg_rank,
            game.away_oppppg_rank,game.away_timezone,game.home_timezone,game.away_first_quarter,game.away_second_quarter,away_first_second_quarter,
            game.away_third_quarter,away_first_sec_third_quarter,game.away_forth_quarter,
            game.away_ot_quarter,'',game.home_next_game,game.home_next_fly,game.home_last_game,game.home_last_fly,game.home_team,
            game.home_win_rank,'',game.home_team_city,game.home_team_next_city,game.home_ppg_rank,game.home_oppppg_rank,game.home_timezone,
            game.home_first_quarter,game.home_second_quarter,home_first_second_quarter,game.home_third_quarter,
            home_first_sec_third_quarter,game.home_forth_quarter,'',game.home_ot_quarter,
            '','','','','',game.away_score,game.home_score,away_home_score,game.first_point,game.second_point,
            '','','','',game.total_point,first_ou,second_ou,total_ou,
            game.first_closer_total,game.second_closer_total,game.full_closer_total,game.first_half_bigger,
            game.second_half_bigger,game.fullgame_bigger,game.first_closer_side,game.second_closer_side,'',game.full_closer_side,
            game.home_last_ot,game.away_last_ot,'','','','','','','','','','','','','','','','','','','','','','','','','','','','',
            '','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',
            game.pace,game.away_ortg,game.home_ortg,game.away_last_home,game.away_next_home,away_last_next_home,
            '',game.home_last_away,game.home_next_away,home_last_next_away,'','','','','',game.fg_road_2000,game.fg_home_2000,
            game.fg_diff_2000,game.fg_count_2000,'',game.fg_road_1990,game.fg_home_1990,game.fg_diff_1990,game.fg_count_1990,game.first_half_road_2000,
            game.first_half_home_2000,game.first_half_diff_2000,game.first_half_count_2000,'',game.first_half_road_1990,game.first_half_home_1990,
            game.first_half_diff_1990,game.first_half_count_1990,game.second_half_road_2000,game.second_half_home_2000,game.second_half_diff_2000,
            game.second_half_count_2000,'',game.second_half_road_1990,game.second_half_home_1990,game.second_half_diff_1990,game.second_half_count_1990,
            '',game.fg_total_pt_2000,game.fg_total_line_2000,game.fg_total_diff_2000,game.fg_total_count_2000,game.first_half_total_pt_2000,
            game.first_half_total_line_2000,game.first_half_total_diff_2000,game.first_half_total_count_2000,game.second_half_total_pt_2000,
            game.second_half_total_line_2000,game.second_half_total_diff_2000,game.second_half_total_count_2000,game.fg_total_pt_1990,game.fg_total_line_1990,
            game.first_half_total_pt_1990,game.first_half_total_line_1990,game.second_half_total_pt_1990,game.second_half_total_line_1990,
            '','','','','','','','','',game.away_player1_name,game.away_player1_birthday.nil? ? '' : game.away_player1_birthday[0..11],
            game.away_player2_name,game.away_player2_birthday.nil? ? '' : game.away_player2_birthday[0..11],
            game.away_player3_name,game.away_player3_birthday.nil? ? '' : game.away_player3_birthday[0..11],
            game.away_player4_name,game.away_player4_birthday.nil? ? '' : game.away_player4_birthday[0..11],
            game.away_player5_name,game.away_player5_birthday.nil? ? '' : game.away_player5_birthday[0..11],
            game.away_player6_name,game.away_player6_birthday.nil? ? '' : game.away_player6_birthday[0..11],
            game.away_player7_name,game.away_player7_birthday.nil? ? '' : game.away_player7_birthday[0..11],
            game.away_player8_name,game.away_player8_birthday.nil? ? '' : game.away_player8_birthday[0..11],
            game.home_player1_name,game.home_player1_birthday.nil? ? '' : game.home_player1_birthday[0..11],
            game.home_player2_name,game.home_player2_birthday.nil? ? '' : game.home_player2_birthday[0..11],
            game.home_player3_name,game.home_player3_birthday.nil? ? '' : game.home_player3_birthday[0..11],
            game.home_player4_name,game.home_player4_birthday.nil? ? '' : game.home_player4_birthday[0..11],
            game.home_player5_name,game.home_player5_birthday.nil? ? '' : game.home_player5_birthday[0..11],
            game.home_player6_name,game.home_player6_birthday.nil? ? '' : game.home_player6_birthday[0..11],
            game.home_player7_name,game.home_player7_birthday.nil? ? '' : game.home_player7_birthday[0..11],
            game.home_player8_name,game.home_player8_birthday.nil? ? '' : game.home_player8_birthday[0..11]

          ]
          sheet1.insert_row(sheet_row, row_to_insert)
          sheet_row = sheet_row + 1
    end
    File.delete(nba_data_file_path)
    # Write out the Workbook again
    book.write(nba_data_file_path)
    obj = S3.object("nba_data/nba_data_sheet.xls")
    obj.upload_file(nba_data_file_path, acl:'public-read')
    puts obj.public_url
  end
end