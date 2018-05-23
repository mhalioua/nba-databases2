namespace :job do
  task :getDate => [:environment] do |t, args|
    puts "----------Get Games----------"
    include Api
    Time.zone = 'Eastern Time (US & Canada)'
    index_date = Date.new(2010,5,15)
    while index_date <= Date.new(2010,8,18)
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
        next if game_id == '300710096'
        unless game = Wnba.find_by(game_id: game_id)
          game = Wnba.create(game_id: game_id)
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

        addingDate = date + 4.hours + @team_timezone[home_team].hours
        game.update(away_team: away_team, home_team: home_team, home_abbr: home_abbr, away_abbr: away_abbr, game_date: date, year: addingDate.strftime("%Y"), date: addingDate.strftime("%b %e"), time: addingDate.strftime("%I:%M%p"), est_time: date.strftime("%I:%M%p"), week: addingDate.strftime("%a"), away_fga: away_fga_value, away_fta: away_fta_value, away_toValue: away_to_value, away_orValue: away_or_value, home_fga: home_fga_value, home_fta: home_fta_value, home_toValue: home_to_value, home_orValue: home_or_value)
      end
      index_date = index_date + 1.days
    end
  end

  task :fix => [:environment] do
    games = Wnba.where('away_fga is null')
    games.each do |game|
      url = "http://www.espn.com/wnba/boxscore?gameId=#{game.game_id}"
      doc = download_document(url)
      puts url
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
      game.update(away_fga: away_fga_value, away_fta: away_fta_value, away_toValue: away_to_value, away_orValue: away_or_value, home_fga: home_fga_value, home_fta: home_fta_value, home_toValue: home_to_value, home_orValue: home_or_value)
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
    link = "https://www.sportsbookreview.com/betting-odds/wnba-basketball/2nd-half/?date="
    Rake::Task["job:getSecondLines"].invoke("second", link)
    Rake::Task["job:getSecondLines"].reenable

    link = "https://www.sportsbookreview.com/betting-odds/wnba-basketball/?date="
    Rake::Task["job:getSecondLines"].invoke("full", link)
    Rake::Task["job:getSecondLines"].reenable

    link = "https://www.sportsbookreview.com/betting-odds/wnba-basketball/totals/1st-half/?date="
    Rake::Task["job:getSecondLines"].invoke("firstTotal", link)
    Rake::Task["job:getSecondLines"].reenable

    link = "https://www.sportsbookreview.com/betting-odds/wnba-basketball/totals/2nd-half/?date="
    Rake::Task["job:getSecondLines"].invoke("secondTotal", link)
    Rake::Task["job:getSecondLines"].reenable

    link = "https://www.sportsbookreview.com/betting-odds/wnba-basketball/totals/?date="
    Rake::Task["job:getSecondLines"].invoke("fullTotal", link)
    Rake::Task["job:getSecondLines"].reenable
  end

  task :getFirstLines => [:environment] do
    include Api
    games = Wnba.all
    puts "----------Get First Lines----------"

    index_date = Date.new(2011, 6, 4)
    while index_date <= Date.new(2011, 6 ,4) do
      game_day = index_date.strftime("%Y%m%d")
      puts game_day
      url = "https://www.sportsbookreview.com/betting-odds/wnba-basketball/1st-half/?date=#{game_day}"
      doc = download_document(url)
      elements = doc.css(".event-holder")
      elements.each do |element|
        if element.children[0].children[4].children.size < 5
          next
        end

        score_element = element.children[0].children[8]
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

    index_date = Date.new(2010, 5, 15)
    while index_date <= Date.new(2017, 9 ,3) do
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
end