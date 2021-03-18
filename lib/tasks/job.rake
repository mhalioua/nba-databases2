namespace :job do
  # WNBA
  task :getDate => [:environment] do |t, args|
    puts "----------Get Games----------"
    include Api
    Time.zone = 'Eastern Time (US & Canada)'
    index_date = Date.new(2013, 5, 9)
    while index_date <= Date.new(2013, 10, 10)
      game_date = index_date.strftime("%Y%m%d")
      url = "http://www.espn.com/wnba/schedule/_/date/#{game_date}"
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
        next if game_id == '400470769'
        game = Wnba.find_or_create_by(game_id: game_id)
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

        url = "http://www.espn.com/wnba/game?gameId=#{game_id}"
        doc = download_document(url)
        puts url
        element = doc.css(".game-date-time").first
        game_date = element.children[1]['data-date']
        date = DateTime.parse(game_date).in_time_zone

        url = "http://www.espn.com/wnba/boxscore?gameId=#{game_id}"
        doc = download_document(url)
        puts url
        element = doc.css(".highlight")
        if element.size > 3 && element[2].children.size > 10
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

        addingDate = date + 4.hours + @team_timezone[home_team].hours
        game.update(
          away_team: away_team,
          home_team: home_team,
          home_abbr: home_abbr,
          away_abbr: away_abbr,
          game_date: date,
          year: addingDate.strftime("%Y"),
          date: addingDate.strftime("%b %e"),
          time: addingDate.strftime("%I:%M%p"),
          est_time: date.strftime("%I:%M%p"),
          week: addingDate.strftime("%a"),
          away_fga: away_fga_value,
          away_fta: away_fta_value,
          away_toValue: away_to_value,
          away_orValue: away_or_value,
          home_fga: home_fga_value,
          home_fta: home_fta_value,
          home_toValue: home_to_value,
          home_orValue: home_or_value
        )
      end
      index_date = index_date + 1.days
    end
  end

  task :getLinkGame => [:environment] do
    include Api
    puts "----------Get Link Games----------"

    Time.zone = 'Eastern Time (US & Canada)'
    games = Wnba.where("away_last_game is null")
    puts games.size

    games.each do |game|
      game_count = Wnba.where('year = ? AND date = ?', game.year, game.date).size
      game.update(game_count: game_count)

      home_team = game.home_team
      away_team = game.away_team
      game_date = game.game_date

      away_last_game = ""
      away_team_prev = Wnba.where("home_team = ? AND game_date < ?", away_team, game_date).or(Wnba.where("away_team = ? AND game_date < ?", away_team, game_date)).order(:game_date).last
      if away_team_prev
        away_last_game = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(away_team_prev.game_date).in_time_zone.to_date ).to_i - 1
      end

      away_next_game = ""
      away_team_next = Wnba.where("home_team = ? AND game_date > ?", away_team, game_date).or(Wnba.where("away_team = ? AND game_date > ?", away_team, game_date)).order(:game_date).first
      if away_team_next
        away_next_game = (DateTime.parse(away_team_next.game_date).in_time_zone.to_date  - DateTime.parse(game_date).in_time_zone.to_date ).to_i - 1
      end

      home_last_game = ""
      home_team_prev = Wnba.where("home_team = ? AND game_date < ?", home_team, game_date).or(Wnba.where("away_team = ? AND game_date < ?", home_team, game_date)).order(:game_date).last
      if home_team_prev
        home_last_game = (DateTime.parse(game_date).in_time_zone.to_date - DateTime.parse(home_team_prev.game_date).in_time_zone.to_date ).to_i - 1
      end

      home_next_game = ""
      home_team_next = Wnba.where("home_team = ? AND game_date > ?", home_team, game_date).or(Wnba.where("away_team = ? AND game_date > ?", home_team, game_date)).order(:game_date).first
      if home_team_next
        home_next_game = (DateTime.parse(home_team_next.game_date).in_time_zone.to_date  - DateTime.parse(game_date).in_time_zone.to_date ).to_i - 1
      end

      game.update(away_last_game: away_last_game, away_next_game: away_next_game, home_last_game: home_last_game, home_next_game: home_next_game)
    end
  end

  task :getScore => [:environment] do
    include Api
    puts "----------Get Score----------"

    games = Wnba.where("away_first_quarter is null")
    puts games.size
    games.each do |game|
      game_id = game.game_id

      url = "http://www.espn.com/wnba/playbyplay?gameId=#{game_id}"
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

  task :getLines => [:environment] do
    Rake::Task["job:getFirstLines"].invoke
    Rake::Task["job:getFirstLines"].reenable

    link = "https://classic.sportsbookreview.com/betting-odds/wnba-basketball/2nd-half/?date="
    Rake::Task["job:getSecondLines"].invoke("second", link)
    Rake::Task["job:getSecondLines"].reenable

    link = "https://classic.sportsbookreview.com/betting-odds/wnba-basketball/?date="
    Rake::Task["job:getSecondLines"].invoke("full", link)
    Rake::Task["job:getSecondLines"].reenable

    link = "https://classic.sportsbookreview.com/betting-odds/wnba-basketball/totals/1st-half/?date="
    Rake::Task["job:getSecondLines"].invoke("firstTotal", link)
    Rake::Task["job:getSecondLines"].reenable

    link = "https://classic.sportsbookreview.com/betting-odds/wnba-basketball/totals/2nd-half/?date="
    Rake::Task["job:getSecondLines"].invoke("secondTotal", link)
    Rake::Task["job:getSecondLines"].reenable

    link = "https://classic.sportsbookreview.com/betting-odds/wnba-basketball/totals/?date="
    Rake::Task["job:getSecondLines"].invoke("fullTotal", link)
    Rake::Task["job:getSecondLines"].reenable
  end

  task :getFirstLines => [:environment] do
    include Api
    games = Wnba.all
    puts "----------Get First Lines----------"

    index_date = Date.new(2013, 5, 9)
    while index_date <= Date.new(2013, 10, 10) do
      game_day = index_date.strftime("%Y%m%d")
      puts game_day
      url = "https://classic.sportsbookreview.com/betting-odds/wnba-basketball/1st-half/?date=#{game_day}"
      doc = download_document(url)
      elements = doc.css(".event-holder")
      elements.each do |element|
        if element.children[0].children[4].children.size < 5
          next
        end

        score_element = element.children[0].children[8]

        if score_element.children[1].text == ""
          score_element = element.children[0].children[10]
        end

        if score_element.children[1].text == ""
          score_element = element.children[0].children[9]
        end

        if score_element.children[1].text == ""
          score_element = element.children[0].children[11]
        end

        home_name     = element.children[0].children[4].children[1].text
        away_name     = element.children[0].children[4].children[0].text
        closer      = score_element.children[1].text
        opener      = element.children[0].children[6].children[1].text

        home_name = @sport_team[home_name] if @sport_team[home_name]
        away_name = @sport_team[away_name] if @sport_team[away_name]

        game_time = element.children[0].children[3].text
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

        date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 4.hours +  hour.hours

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
          update_game.update(first_opener_side: opener_side, first_closer_side: closer_side)
        end
      end
      index_date = index_date + 1.days
    end
  end
    
  task :getSecondLines, [:type, :game_link] => [:environment] do |t, args|
    include Api
    games = Wnba.all
    game_link = args[:game_link]
    type = args[:type]
    puts "----------Get #{type} Lines----------"

    index_date = Date.new(2013, 5, 9)
    while index_date <= Date.new(2013, 10, 10) do
      game_day = index_date.strftime("%Y%m%d")
      puts game_day
      url = "#{game_link}#{game_day}"
      doc = download_document(url)
      elements = doc.css(".event-holder")
      elements.each do |element|
        if element.children[0].children[4].children.size < 5
          next
        end

        score_element = element.children[0].children[8]

        if score_element.children[1].text == ""
          score_element = element.children[0].children[10]
        end

        if score_element.children[1].text == ""
          score_element = element.children[0].children[9]
        end

        if score_element.children[1].text == ""
          score_element = element.children[0].children[11]
        end

        home_name     = element.children[0].children[4].children[1].text
        away_name     = element.children[0].children[4].children[0].text
        closer      = score_element.children[1].text
        opener      = element.children[0].children[6].children[1].text

        home_name = @sport_team[home_name] if @sport_team[home_name]
        away_name = @sport_team[away_name] if @sport_team[away_name]
        
        game_time = element.children[0].children[3].text
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

        date = Time.new(game_day[0..3], game_day[4..5], game_day[6..7]).change(hour: 0, min: min).in_time_zone('Eastern Time (US & Canada)') + 4.hours +  hour.hours

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
          if type == "second"
            update_game.update(second_opener_side: opener_side, second_closer_side: closer_side)
          elsif type == "full"
            update_game.update(full_opener_side: opener_side, full_closer_side: closer_side)
          elsif type == "firstTotal"
            update_game.update(first_opener_total: opener_side, first_closer_total: closer_side)
          elsif type == "secondTotal"
            update_game.update(second_opener_total: opener_side, second_closer_total: closer_side)
          elsif type == "fullTotal"
            update_game.update(full_opener_total: opener_side, full_closer_total: closer_side)
          end
        end
      end
      index_date = index_date + 1.days
    end
  end

  task :nbaplaybyplay => :environment do
    include Api
    games = Wnba.where('home_fga_second is null')
    games.each do |game|
      url="http://www.espn.com/wnba/playbyplay?gameId=#{game.game_id}"
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
      away_fgm = 0
      away_fga = 0
      away_ptm = 0
      away_pta = 0
      away_ftm = 0
      away_fta = 0
      away_to = 0
      away_pf = 0
      away_or = 0
      count = 0
      elements.each_with_index do |element, index|
        if element.children[0].text.squish == 'time'
          count = count + 1
          next
        end
        if count == 3
          count = count + 1
          game.update(
            home_fga_first: home_fga + home_pta,
            home_fgm_first: home_fgm + home_ptm,
            home_ptm_first: home_ptm,
            home_pta_first: home_pta,
            home_fta_first: home_fta,
            home_ftm_first: home_ftm,
            home_or_first: home_or,
            home_to_first: home_to,
            home_foul_first: home_pf,
            away_fga_first: away_fga + away_pta,
            away_fgm_first: away_fgm + away_ptm,
            away_ptm_first: away_ptm,
            away_pta_first: away_pta,
            away_fta_first: away_fta,
            away_ftm_first: away_ftm,
            away_or_first: away_or,
            away_to_first: away_to,
            away_foul_first: away_pf
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
          away_fgm = 0
          away_fga = 0
          away_ptm = 0
          away_pta = 0
          away_ftm = 0
          away_fta = 0
          away_to = 0
          away_pf = 0
          away_or = 0
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
        home_foul_second: home_pf,
        away_fga_second: away_fga + away_pta,
        away_fgm_second: away_fgm + away_ptm,
        away_ptm_second: away_ptm,
        away_pta_second: away_pta,
        away_fta_second: away_fta,
        away_ftm_second: away_ftm,
        away_or_second: away_or,
        away_to_second: away_to,
        away_foul_second: away_pf
      )
    end
  end

  #####

  @sport_team = {
    'Phoenix Mercury' => 'Phoenix',
    'Indiana Fever' => 'Indiana',
    'Connecticut Sun' => 'Connecticut',
    'Minnesota Lynx' => 'Minnesota',
    'Chicago Sky' => 'Chicago',
    'Atlanta Dream' => 'Atlanta',
    'San Antonio Stars' => 'San Antonio',
    'Washington Mystics' => 'Washington',
    'Tulsa Shock' => 'Tulsa',
    'New York Liberty' => 'New York',
    'Seattle Storm' => 'Seattle',
    'L.A. Sparks' => 'Los Angeles',
    'Dallas Wings' => 'Dallas'
  }

  @team_timezone = {
    'Las Vegas' => -7,
    'Seattle' => -7,
    'Washington' => -4,
    'New York' => -4,
    'Chicago' => -5,
    'Minnesota' => -5,
    'Connecticut' => -4,
    'Phoenix' => -7,
    'Atlanta' => -4,
    'Los Angeles' => -7,
    'Indiana' => -4,
    'Dallas' => -5,
    'San Antonio' => -5,
    'Tulsa' => -5,
    'Detroit' => -4,
    'Sacramento' => -7
  }

  ### NBA DATABASE IGNORE
  task :importNbaDatabase => :environment do
    require 'csv'
    filename = File.join Rails.root, 'csv', "Book2.csv"
    CSV.foreach(filename, headers: true) do |row|
      game = row.to_h
      Fullseason.create(game)
    end
  end

  task :getFiltervalue => :environment do
    games = NbaDatabase.where('fg_total_count_2000 is null')
    games.each do |game|
      countItem = Fullseason.where("awaylastfly = ? AND awaynextfly = ? AND roadlast = ? AND roadnext = ? AND homenext = ? AND homelast = ? AND homenextfly = ? AND homelastfly = ? AND id != ?", game.away_is_last_game_home, game.away_is_next_game_home, game.away_last, game.away_next, game.home_next, game.home_last, game.home_is_last_game_home, game.home_is_next_game_home, (game.id.to_i + 107398))
      secondItem = Secondtravel.where("awaylastfly = ? AND awaynextfly = ? AND roadlast = ? AND roadnext = ? AND homenext = ? AND homelast = ? AND homenextfly = ? AND homelastfly = ?", game.away_is_last_game_home, game.away_is_next_game_home, game.away_last, game.away_next, game.home_next, game.home_last, game.home_is_last_game_home, game.home_is_next_game_home)

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
      first_half_difference = game.away_first_half.to_f - game.home_first_half.to_f - game.first_half_side.to_f
      if first_half_difference > 0
        first_half_bigger = "AWAY"
      elsif first_half_difference < 0
        first_half_bigger = "HOME"
      else
        first_half_bigger = "0"
      end

      second_half_bigger = "0"
      second_half_difference = game.away_second_half.to_f - game.home_second_half.to_f - game.second_half_side.to_f
      if second_half_difference > 0
        second_half_bigger = "AWAY"
      elsif second_half_difference < 0
        second_half_bigger = "HOME"
      else
        second_half_bigger = "0"
      end

      fullgame_bigger = "0"
      fullgame_difference = game.road.to_f - game.home.to_f - game.fullgame_side.to_f
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

  task :addBiggerToFullseason => :environment do
    games = Fullseason.where('first_half_bigger is null AND firstside is not null')
    games.each do |game|
      first_half_bigger = "0"
      first_half_difference = game.roadfirsthalf.to_f - game.homefirsthalf.to_f - game.firstside.to_f
      if first_half_difference > 0
        first_half_bigger = "AWAY"
      elsif first_half_difference < 0
        first_half_bigger = "HOME"
      else
        first_half_bigger = "0"
      end

      second_half_bigger = "0"
      second_half_difference = game.roadthird.to_f + game.roadforth.to_f - game.homethird.to_f - game.homeforth.to_f - game.secondside.to_f
      if second_half_difference > 0
        second_half_bigger = "AWAY"
      elsif second_half_difference < 0
        second_half_bigger = "HOME"
      else
        second_half_bigger = "0"
      end

      fullgame_bigger = "0"
      fullgame_difference = game.roadtotal.to_f - game.hometotal.to_f - game.fgside.to_f
      if fullgame_difference > 0
        fullgame_bigger = "AWAY"
      elsif fullgame_difference < 0
        fullgame_bigger = "HOME"
      else
        fullgame_bigger = "0"
      end

      game.update(
          first_half_bigger: first_half_bigger,
          second_half_bigger: second_half_bigger,
          fullgame_bigger: fullgame_bigger
      )
    end
  end
  ###

  # CBB
  task :getCBBPlayer => :environment do
    include Api
    url = "https://basketball.realgm.com/ncaa/teams"
    doc = download_document(url)
    team_links = doc.css("tbody tr td:first-child a")
    team_links.each do |team_link|
      team_name = team_link.text
      team_url = 'https://basketball.realgm.com' + team_link['href'] + 'players'
      team_doc = download_document(team_url)
      players = team_doc.css("tbody tr")
      players.each do |player|
        next if player.children[15]['rel'] != '2019'
        Cbb.find_or_create_by(player: player.children[1].text, birthdate: player.children[9].text, team_name: team_name)
      end
    end
  end
end