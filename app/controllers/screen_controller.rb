class IndexController < ApplicationController
  def rest
    @match = {
      'PHX' => 'PHO',
      'UTAH' => 'UTA',
      'WSH' => 'WAS'
    }
    @game_id = params[:id]
    @game = Nba.find_by(game_id: @game_id)
    @head = @game.away_team + " @ " + @game.home_team

    @home_abbr = @game.home_abbr
    @away_abbr = @game.away_abbr

    @now = Date.strptime(@game.game_date)
    @now = Time.now if @now > Time.now

    @away_last = Nba.where("home_abbr = ? AND game_date < ? AND total_point != 0", @away_abbr, @now).or(Nba.where("away_abbr = ? AND game_date < ? AND total_point != 0", @away_abbr, @now)).order(:game_date).last
    @home_last = Nba.where("home_abbr = ? AND game_date < ? AND total_point != 0", @home_abbr, @now).or(Nba.where("away_abbr = ? AND game_date < ? AND total_point != 0", @home_abbr, @now)).order(:game_date).last

    @away_flag = @away_abbr == @away_last.away_abbr ? 0 : 1
    @home_flag = @home_abbr == @home_last.away_abbr ? 0 : 1

    @date_id = Date.strptime(@game.game_date).strftime("%Y-%m-%d")

    @away_players = @away_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @away_flag).order(:state).to_a
    @away_players_search = @away_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @away_flag).order(:state)
    @away_players_group1 = []
    @away_players_group2 = []
    @away_players_group3 = @away_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @away_flag).order(:state).to_a
    @away_starter_abbr = @away_abbr
    @away_starter_abbr = @match[@away_starter_abbr] if @match[@away_starter_abbr]
    @away_starters = Starter.where('team = ? AND time = ?', @away_starter_abbr, DateTime.parse(@game.game_date).strftime("%FT%T+00:00")).order(:index)
    @away_starters.each do |away_starter|
      selected_player = @away_players_search.select { |element|
        player_name = element.player_fullname
        player_name = player_name.gsub('-', ' ')
        element_index = player_name.rindex(" ")
        player_name = away_starter.player_name
        player_name = player_name.gsub('-', ' ')
        away_starter_index = player_name.rindex(" ")
        element.player_fullname[element_index + 1..-1] == away_starter.player_name[away_starter_index + 1..-1] }.first
      if selected_player
        selected_player.position = away_starter.position
        @away_players_group3.delete(selected_player)
        if away_starter.position == 'PG' || away_starter.position == 'SG'
          @away_players_group1.push(selected_player)
        else
          @away_players_group2.push(selected_player)
        end
      else
        additional_player = Player.where("player_fullname = ? AND game_date < ?", away_starter.player_name, @now).order(:game_date).last
        additional_player = Player.where("player_name = ? AND game_date < ?", away_starter.player_name, @now).order(:game_date).last unless additional_player
        if additional_player
          additional_player.position = away_starter.position
          @away_players.push(additional_player)
          if away_starter.position == 'PG' || away_starter.position == 'SG'
            @away_players_group1.push(additional_player)
          else
            @away_players_group2.push(additional_player)
          end
        end
      end
    end

    @home_players = @home_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @home_flag).order(:state).to_a
    @home_players_search = @home_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @home_flag).order(:state)
    @home_players_group1 = []
    @home_players_group2 = []
    @home_players_group3 = @home_last.players.where("team_abbr = ? AND player_fullname is not null AND player_fullname != ''", @home_flag).order(:state).to_a
    @home_starter_abbr = @home_abbr
    @home_starter_abbr = @match[@home_starter_abbr] if @match[@home_starter_abbr]
    @home_starters = Starter.where('team = ? AND time = ?', @home_starter_abbr, DateTime.parse(@game.game_date).strftime("%FT%T+00:00")).order(:index)
    @home_starters.each do |home_starter|
      selected_player = @home_players_search.select { |element|
        player_name = element.player_fullname
        player_name = player_name.gsub('-', ' ')
        element_index = player_name.rindex(" ")
        player_name = home_starter.player_name
        player_name = player_name.gsub('-', ' ')
        home_starter_index = player_name.rindex(" ")
        element.player_fullname[element_index + 1..-1] == home_starter.player_name[home_starter_index + 1..-1] }.first
      if selected_player
        selected_player.position = home_starter.position
        @home_players_group3.delete(selected_player)
        if home_starter.position == 'PG' || home_starter.position == 'SG'
          @home_players_group1.push(selected_player)
        else
          @home_players_group2.push(selected_player)
        end
      else
        additional_player = Player.where("player_fullname = ? AND game_date < ?", home_starter.player_name, @now).order(:game_date).last
        additional_player = Player.where("player_name = ? AND game_date < ?", home_starter.player_name, @now).order(:game_date).last unless additional_player
        if additional_player
          additional_player.position = home_starter.position
          @home_players.push(additional_player)
          if home_starter.position == 'PG' || home_starter.position == 'SG'
            @home_players_group1.push(additional_player)
          else
            @home_players_group2.push(additional_player)
          end
        end
      end
    end
    @break = [9, 17, 19]
    @home_team_info = Team.find_by(abbr: @home_abbr)
    @away_team_info = Team.find_by(abbr: @away_abbr)
    @away_last_games = Nba.where("home_team = ? AND game_date < ?", @game.away_team, @game.game_date).or(Nba.where("away_team = ? AND game_date < ?", @game.away_team, @game.game_date)).order(game_date: :desc).limit(12)
    @away_stl = 0
    @away_blk = 0
    @away_or = 0
    @away_to = 0
    @away_last_games.each do |last_game|
      if last_game.home_team == @game.away_team
        @away_stl = @away_stl + last_game.home_stl.to_i
        @away_blk = @away_blk + last_game.home_blk.to_i
        @away_or = @away_or + last_game.home_orValue.to_i
        @away_to = @away_to + last_game.home_toValue.to_i
      else
        @away_stl = @away_stl + last_game.away_stl.to_i
        @away_blk = @away_blk + last_game.away_blk.to_i
        @away_or = @away_or + last_game.away_orValue.to_i
        @away_to = @away_to + last_game.away_toValue.to_i
      end
    end
    @away_count = @away_last_games.count
    if @away_count
      @away_stl = (@away_stl.to_f / @away_count).round(2)
      @away_blk = (@away_blk.to_f / @away_count).round(2)
      @away_or = (@away_or.to_f / @away_count).round(2)
      @away_to = (@away_to.to_f / @away_count).round(2)
    end

    @home_last_games = Nba.where("home_team = ? AND game_date < ?", @game.home_team, @game.game_date).or(Nba.where("away_team = ? AND game_date < ?", @game.home_team, @game.game_date)).order(game_date: :desc).limit(12)
    @home_stl = 0
    @home_blk = 0
    @home_or = 0
    @home_to = 0

    @home_last_games.each do |last_game|
      if last_game.home_team == @game.home_team
        @home_stl = @home_stl + last_game.home_stl.to_i
        @home_blk = @home_blk + last_game.home_blk.to_i
        @home_or = @home_or + last_game.home_orValue.to_i
        @home_to = @home_to + last_game.home_toValue.to_i
      else
        @home_stl = @home_stl + last_game.away_stl.to_i
        @home_blk = @home_blk + last_game.away_blk.to_i
        @home_or = @home_or + last_game.away_orValue.to_i
        @home_to = @home_to + last_game.away_toValue.to_i
      end
    end
    @home_count = @home_last_games.count
    if @home_count
      @home_stl = (@home_stl.to_f / @home_count).round(2)
      @home_blk = (@home_blk.to_f / @home_count).round(2)
      @home_or = (@home_or.to_f / @home_count).round(2)
      @home_to = (@home_to.to_f / @home_count).round(2)
    end

    @away_players_starters = @away_players_group1 + @away_players_group2
    @home_players_starters = @home_players_group1 + @home_players_group2

    @away_avg_stl = 0
    @away_avg_blk = 0
    @away_avg_or = 0
    @away_avg_to = 0
    @away_players_starters.each do |player|
      last_players = Player.where("player_name = ? AND mins <> 0", player.player_name).order(game_date: :desc).limit(12)
      average_mins = 0
      average_stl = 0
      average_blk = 0
      average_or = 0
      average_to = 0
      last_players_count = last_players.count
      last_players.each do |last_player|
        average_mins = average_mins + last_player.mins
        average_stl = average_stl + last_player.stlValue
        average_blk = average_blk + last_player.blkValue
        average_or = average_or + last_player.orValue
        average_to = average_to + last_player.toValue
      end
      average_mins = average_mins.to_f / last_players_count
      average_stl = average_stl.to_f / last_players_count
      average_blk = average_blk.to_f / last_players_count
      average_or = average_or.to_f / last_players_count
      average_to = average_to.to_f / last_players_count
      @away_avg_stl = @away_avg_stl + 48 / average_mins * average_stl
      @away_avg_blk = @away_avg_blk + 48 / average_mins * average_blk
      @away_avg_or = @away_avg_or + 48 / average_mins * average_or
      @away_avg_to = @away_avg_to + 48 / average_mins * average_to
    end

    @home_avg_stl = 0
    @home_avg_blk = 0
    @home_avg_or = 0
    @home_avg_to = 0
    @home_players_starters.each do |player|
      last_players = Player.where("player_name = ? AND mins <> 0", player.player_name).order(game_date: :desc).limit(12)
      average_mins = 0
      average_stl = 0
      average_blk = 0
      average_or = 0
      average_to = 0
      last_players_count = last_players.count
      last_players.each do |last_player|
        average_mins = average_mins + last_player.mins
        average_stl = average_stl + last_player.stlValue
        average_blk = average_blk + last_player.blkValue
        average_or = average_or + last_player.orValue
        average_to = average_to + last_player.toValue
      end
      average_mins = average_mins.to_f / last_players_count
      average_stl = average_stl.to_f / last_players_count
      average_blk = average_blk.to_f / last_players_count
      average_or = average_or.to_f / last_players_count
      average_to = average_to.to_f / last_players_count
      @home_avg_stl = @home_avg_stl + 48 / average_mins * average_stl
      @home_avg_blk = @home_avg_blk + 48 / average_mins * average_blk
      @home_avg_or = @home_avg_or + 48 / average_mins * average_or
      @home_avg_to = @home_avg_to + 48 / average_mins * average_to
    end

    @team_more = {
      'Atlanta' => 'EAST',
      'Boston' => 'EAST',
      'Brooklyn' => 'EAST',
      'Charlotte' => 'EAST',
      'Chicago' => 'MID-WEST',
      'Cleveland' => 'EAST',
      'Dallas' => 'TEXANS',
      'Denver' => 'ROCKIES',
      'Detroit' => 'EAST',
      'Golden State' => 'WEST COAST',
      'Houston' => 'TEXANS',
      'Indiana' => 'EAST',
      'LAC' => 'WEST COAST',
      'LAL' => 'WEST COAST',
      'Memphis' => 'NULL',
      'Miami' => 'EAST',
      'Milwaukee' => 'MID-WEST',
      'Minnesota' => 'MID-WEST',
      'New Jersey' => 'EAST',
      'New Orleans' => 'NULL',
      'New York' => 'EAST',
      'NO/Oklahoma City' => 'NULL',
      'Oklahoma City' => 'NULL',
      'Orlando' => 'EAST',
      'Philadelphia' => 'EAST',
      'Phoenix' => 'NULL',
      'Portland' => 'WEST COAST',
      'Sacramento' => 'WEST COAST',
      'San Antonio' => 'TEXANS',
      'Seattle' => 'NULL',
      'Toronto' => 'EAST',
      'Utah' => 'ROCKIES',
      'Vancouver' => 'NULL',
      'Washington' => 'EAST'
    }

    firstItem = Fullseason.where(homemore: @team_more[@game.home_team] ? @team_more[@game.home_team] : "NULL", roadmore: @team_more[@game.away_team] ? @team_more[@game.away_team] : "NULL")
    secondItem = Fullseason.where(hometeam: @game.home_team)
    thirdItem = Fullseason.where(week: @game.week)
    @firstItem_result = {
      first: firstItem.average(:firstpoint).to_f.round(2),
      second: firstItem.average(:secondpoint).to_f.round(2),
      full: firstItem.average(:totalpoint).to_f.round(2),
      count: firstItem.count(:totalpoint).to_i
    }
    @secondItem_result = {
      first: secondItem.average(:firstpoint).to_f.round(2),
      second: secondItem.average(:secondpoint).to_f.round(2),
      full: secondItem.average(:totalpoint).to_f.round(2),
      count: secondItem.count(:totalpoint).to_i
    }
    @thirdItem_result = {
      first: thirdItem.average(:firstpoint).to_f.round(2),
      second: thirdItem.average(:secondpoint).to_f.round(2),
      full: thirdItem.average(:totalpoint).to_f.round(2),
      count: thirdItem.count(:totalpoint).to_i
    }

    secondItem_secondtravel = Secondtravel.where(hometeam: @game.home_team)
    thirdItem_secondtravel = Secondtravel.where(week: @game.week)
    @firstItem_result_secondtravel = {
      first: '',
      second: '',
      full: '',
      count: ''
    }
    @secondItem_result_secondtravel = {
      first: secondItem_secondtravel.average(:firstpoint).to_f.round(2),
      second: secondItem_secondtravel.average(:secondpoint).to_f.round(2),
      full: secondItem_secondtravel.average(:totalpoint).to_f.round(2),
      count: secondItem_secondtravel.count(:totalpoint).to_i
    }
    @thirdItem_result_secondtravel = {
      first: thirdItem_secondtravel.average(:firstpoint).to_f.round(2),
      second: thirdItem_secondtravel.average(:secondpoint).to_f.round(2),
      full: thirdItem_secondtravel.average(:totalpoint).to_f.round(2),
      count: thirdItem_secondtravel.count(:totalpoint).to_i
    }

    @game_date = DateTime.parse(@game.game_date)
    year = @game_date.year
    date = @game_date.strftime("%-d-%b")

    @countItem = Fullseason.where("awaylastfly = ? AND awaynextfly = ? AND roadlast = ? AND roadnext = ? AND homenext = ? AND homelast = ? AND homenextfly = ? AND homelastfly = ?", @game.away_last_fly, @game.away_next_fly, @game.away_last_game, @game.away_next_game, @game.home_next_game, @game.home_last_game, @game.home_next_fly, @game.home_last_fly)
    @countItem = @countItem.where("roadteam != ? OR year != ? OR date != ?", @game.away_team, year, date)
    @secondItem = Secondtravel.where("awaylastfly = ? AND awaynextfly = ? AND roadlast = ? AND roadnext = ? AND homenext = ? AND homelast = ? AND homenextfly = ? AND homelastfly = ?", @game.away_last_fly, @game.away_next_fly, @game.away_last_game, @game.away_next_game, @game.home_next_game, @game.home_last_game, @game.home_next_fly, @game.home_last_fly)
    @compares = @game.compares.all

    referee_one_last = @game.referee_one_last
    referee_one_next = @game.referee_one_next
    referee_two_last = @game.referee_two_last
    referee_two_next = @game.referee_two_next
    referee_three_last = @game.referee_three_last
    referee_three_next = @game.referee_three_next
    @referee_last_type = 3
    @referee_next_type = 3

    @referee_filter = []
    referee_one_last = 200 if referee_one_last == nil
    referee_two_last = 200 if referee_two_last == nil
    referee_three_last = 200 if referee_three_last == nil
    if referee_one_last == referee_two_last && referee_two_last == referee_three_last
      @referee_last_type = 1
      @referee_filter.push([referee_one_last, referee_one_last, referee_one_last])
      @referee_filter.push(['-', '-', '-'])
      @referee_filter.push(['-', '-', '-'])
      @referee_filter.push(['-', '-', '-'])
      @referee_filter.push(['-', '-', '-'])
      @referee_filter.push(['-', '-', '-'])
    elsif referee_one_last == referee_two_last || referee_two_last == referee_three_last || referee_one_last == referee_three_last
      @referee_last_type = 2
      one_value = 0
      two_value = 0
      if referee_one_last == referee_two_last
        one_value = referee_one_last
        two_value = referee_three_last
      elsif referee_two_last == referee_three_last
        one_value = referee_two_last
        two_value = referee_one_last
      elsif referee_one_last == referee_three_last
        one_value = referee_one_last
        two_value = referee_two_last
      end

      @referee_filter.push([one_value, one_value, two_value])
      @referee_filter.push([one_value, two_value, one_value])
      @referee_filter.push([two_value, one_value, one_value])
      @referee_filter.push(['-', '-', '-'])
      @referee_filter.push(['-', '-', '-'])
      @referee_filter.push(['-', '-', '-'])
    else
      @referee_last_type = 3
      @referee_filter.push([referee_one_last, referee_two_last, referee_three_last])
      @referee_filter.push([referee_one_last, referee_three_last, referee_two_last])
      @referee_filter.push([referee_two_last, referee_one_last, referee_three_last])
      @referee_filter.push([referee_two_last, referee_three_last, referee_one_last])
      @referee_filter.push([referee_three_last, referee_one_last, referee_two_last])
      @referee_filter.push([referee_three_last, referee_two_last, referee_one_last])
    end

    referee_one_next = 200 if referee_one_next == nil
    referee_two_next = 200 if referee_two_next == nil
    referee_three_next = 200 if referee_three_next == nil

    if referee_one_next == referee_two_next && referee_two_next == referee_three_next
      @referee_next_type = 1
      @referee_filter.push([referee_one_next, referee_one_next, referee_one_next])
      @referee_filter.push(['-', '-', '-'])
      @referee_filter.push(['-', '-', '-'])
      @referee_filter.push(['-', '-', '-'])
      @referee_filter.push(['-', '-', '-'])
      @referee_filter.push(['-', '-', '-'])
    elsif referee_one_next == referee_two_next || referee_two_next == referee_three_next || referee_one_next == referee_three_next
      @referee_next_type = 2
      one_value = 0
      two_value = 0
      if referee_one_next == referee_two_next
        one_value = referee_one_next
        two_value = referee_three_next
      elsif referee_two_next == referee_three_next
        one_value = referee_two_next
        two_value = referee_one_next
      elsif referee_one_next == referee_three_next
        one_value = referee_one_next
        two_value = referee_two_next
      end

      @referee_filter.push([one_value, one_value, two_value])
      @referee_filter.push([one_value, two_value, one_value])
      @referee_filter.push([two_value, one_value, one_value])
      @referee_filter.push(['-', '-', '-'])
      @referee_filter.push(['-', '-', '-'])
      @referee_filter.push(['-', '-', '-'])
    else
      @referee_next_type = 3
      @referee_filter.push([referee_one_next, referee_two_next, referee_three_next])
      @referee_filter.push([referee_one_next, referee_three_next, referee_two_next])
      @referee_filter.push([referee_two_next, referee_one_next, referee_three_next])
      @referee_filter.push([referee_two_next, referee_three_next, referee_one_next])
      @referee_filter.push([referee_three_next, referee_one_next, referee_two_next])
      @referee_filter.push([referee_three_next, referee_two_next, referee_one_next])
    end

    @referee_filter_results = []

    @referee_filter.each_with_index do |referee_filter_element, index|
      if referee_filter_element[0] != '-'
        search_array = []
        if index < 6
          if referee_filter_element[0] > 8
            search_array.push("referee_one_last > 8")
          elsif referee_filter_element[0] > 5
            search_array.push("referee_one_last > 5 AND referee_one_last < 9")
          else
            search_array.push("referee_one_last = #{referee_filter_element[0]}")
          end
          if referee_filter_element[1] > 8
            search_array.push("referee_two_last > 8")
          elsif referee_filter_element[1] > 5
            search_array.push("referee_two_last > 5 AND referee_two_last < 9")
          else
            search_array.push("referee_two_last = #{referee_filter_element[1]}")
          end
          if referee_filter_element[2] > 8
            search_array.push("referee_three_last > 8")
          elsif referee_filter_element[2] > 5
            search_array.push("referee_three_last > 5 AND referee_three_last < 9")
          else
            search_array.push("referee_three_last = #{referee_filter_element[2]}")
          end
        else
          if referee_filter_element[0] > 8
            search_array.push("referee_one_next > 8")
          elsif referee_filter_element[0] > 5
            search_array.push("referee_one_next > 5 AND referee_one_next < 9")
          else
            search_array.push("referee_one_next = #{referee_filter_element[0]}")
          end
          if referee_filter_element[1] > 8
            search_array.push("referee_two_next > 8")
          elsif referee_filter_element[1] > 5
            search_array.push("referee_two_next > 5 AND referee_two_next < 9")
          else
            search_array.push("referee_two_next = #{referee_filter_element[1]}")
          end
          if referee_filter_element[2] > 8
            search_array.push("referee_three_next > 8")
          elsif referee_filter_element[2] > 5
            search_array.push("referee_three_next > 5 AND referee_three_next < 9")
          else
            search_array.push("referee_three_next = #{referee_filter_element[2]}")
          end
        end
        search_array = search_array.join(" AND ")
        referee_filter_result = Referee.where(search_array)
        @referee_filter_results.push(
          [
            referee_filter_result.average(:tp_1h).to_f.round(2),
            referee_filter_result.average(:tp_2h).to_f.round(2),
            (referee_filter_result.average(:away_pf).to_f.round(2) + referee_filter_result.average(:home_pf).to_f.round(2)).round(2),
            (referee_filter_result.average(:away_fta).to_f.round(2) + referee_filter_result.average(:home_fta).to_f.round(2)).round(2),
            referee_filter_result.count(:tp_1h).to_i
          ]
        )
      else
        @referee_filter_results.push(['-', '-', '-', '-', '-'])
      end
    end

    if referee_one_last > referee_two_last
      temp = referee_one_last
      referee_one_last = referee_two_last
      referee_two_last = temp
    end

    if referee_one_last > referee_three_last
      temp = referee_one_last
      referee_one_last = referee_three_last
      referee_three_last = temp
    end

    if referee_two_last > referee_three_last
      temp = referee_two_last
      referee_two_last = referee_three_last
      referee_three_last = temp
    end

    if referee_one_last > 8
      referee_one_last = "9+"
    elsif referee_one_last > 5
      referee_one_last = "6-8"
    else
      referee_one_last = referee_one_last.to_s
    end

    if referee_two_last > 8
      referee_two_last = "9+"
    elsif referee_two_last > 5
      referee_two_last = "6-8"
    else
      referee_two_last = referee_two_last.to_s
    end

    if referee_three_last > 8
      referee_three_last = "9+"
    elsif referee_three_last > 5
      referee_three_last = "6-8"
    else
      referee_three_last = referee_three_last.to_s
    end
    @referee_part = Refereestatic.where("referee_one = ? AND referee_two = ? AND referee_three = ?", referee_one_last, referee_two_last, referee_three_last).first

    @referee_part_one = Referee.where("referee_one = ?", @game.referee_one).or(Referee.where("referee_two = ?", @game.referee_one).or(Referee.where("referee_three = ?", @game.referee_one)))
    @referee_part_one_last = Referee.where("referee_one = ? AND id < 43558", @game.referee_one).or(Referee.where("referee_two = ? AND id < 43558", @game.referee_one).or(Referee.where("referee_three = ? AND id < 43558", @game.referee_one).or(Referee.where("referee_one = ? AND id > 61549", @game.referee_one).or(Referee.where("referee_two = ? AND id > 61549", @game.referee_one).or(Referee.where("referee_three = ? AND id > 61549", @game.referee_one))))))
    @referee_part_two = Referee.where("referee_one = ?", @game.referee_two).or(Referee.where("referee_two = ?", @game.referee_two).or(Referee.where("referee_three = ?", @game.referee_two)))
    @referee_part_two_last = Referee.where("referee_one = ? AND id < 43558", @game.referee_two).or(Referee.where("referee_two = ? AND id < 43558", @game.referee_two).or(Referee.where("referee_three = ? AND id < 43558", @game.referee_two).or(Referee.where("referee_one = ? AND id > 61549", @game.referee_two).or(Referee.where("referee_two = ? AND id > 61549", @game.referee_two).or(Referee.where("referee_three = ? AND id > 61549", @game.referee_two))))))
    @referee_part_three = Referee.where("referee_one = ?", @game.referee_three).or(Referee.where("referee_two = ?", @game.referee_three).or(Referee.where("referee_three = ?", @game.referee_three)))
    @referee_part_three_last = Referee.where("referee_one = ? AND id < 43558", @game.referee_three).or(Referee.where("referee_two = ? AND id < 43558", @game.referee_three).or(Referee.where("referee_three = ? AND id < 43558", @game.referee_three).or(Referee.where("referee_one = ? AND id > 61549", @game.referee_three).or(Referee.where("referee_two = ? AND id > 61549", @game.referee_three).or(Referee.where("referee_three = ? AND id > 61549", @game.referee_three))))))
  end
end
