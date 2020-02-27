class FilterController < ApplicationController
  def index
    @teams = Team.all.order('team')
  end

  def show
    id = params[:id]
    @team = Team.find_by(id: id)
    @games = Nba.where("home_team = ? AND game_date <= ? AND id >= 26796", @team.team, Date.current)
               .or(Nba.where("home_team = ? AND game_date <= ? AND id <= 26573 AND id >= 25261", @team.team, Date.current)).order('id DESC').limit(100)
  end


  def filter
    unless params[:datePicker]
      params[:datePicker] = false
    end
    @datePicker = params[:datePicker]

    unless params[:date]
      params[:date] = Time.now.strftime("%b %d, %Y") + " - " + Time.now.strftime("%b %d, %Y")
    end
    @game_index = params[:date]
    @game_start_index = @game_index[0..12]
    @game_end_index = @game_index[15..27]
    #@games = Nba.where("id >= 26796").or(Nba.where("id <= 26573 AND id >= 25261")).order('id DESC')

    if @datePicker
      #@games = @games.where("game_date <= ?", Date.today.end_of_day)
      @games = Nba.where("game_date <= ?", Date.today.end_of_day).order('id DESC')
    else
      #@games = @games.where("game_date between ? and ?", Date.strptime(@game_start_index, '%b %d, %Y').beginning_of_day, Date.strptime(@game_end_index, '%b %d, %Y').end_of_day)
      @games = Nba.where("game_date between ? and ?", Date.strptime(@game_start_index, '%b %d, %Y').beginning_of_day, Date.strptime(@game_end_index, '%b %d, %Y').end_of_day).order('id DESC')
    end
    @teams = Team.all.order('team')
    @team_city = {
      'Boston' => 'Boston',
      'Indiana' => 'Indianapolis',
      'Minnesota' => 'Minneapolis',
      'Utah' => 'Salt Lake City',
      'Golden State' => 'Oakland',
      'LAC' => 'Los Angeles',
      'LAL' => 'Los Angeles',
      'LA Clippers' => 'Los Angeles',
      'LA Lakers' => 'Los Angeles',
      'NO/Oklahoma City' => 'Oklahoma City',
      'New Jersey' => 'Brooklyn'
    }
    
    @home_team_id = 0
    @away_team_id = 0
    @last_city_home = 0
    @last_city_away = 0
    @next_city_home = 0
    @next_city_away = 0
    @selected_value = 0

    if params[:home_team_id].present?
      @home_team_id = params[:home_team_id].to_i
      @home_team = Team.find_by(id: params[:home_team_id])
      if @home_team != nil
        home_team_name = @home_team.team
        home_team_name = 'LAC' if home_team_name == 'LA Clippers'
        home_team_name = 'LAL' if home_team_name == 'LA Lakers'
        @games = @games.where("home_team = ?", home_team_name) unless @games.empty?
      end
    end

    if params[:away_team_id].present?
      @away_team_id = params[:away_team_id].to_i
      @away_team = Team.find_by(id: params[:away_team_id])
      if @away_team != nil
        away_team_name = @away_team.team
        away_team_name = 'LAC' if away_team_name == 'LA Clippers'
        away_team_name = 'LAL' if away_team_name == 'LA Lakers'
        @games = @games.where("away_team = ?", away_team_name) unless @games.empty?
      end
    end

    if params[:last_city_home].present?
      @last_city_home = params[:last_city_home]
      last_city_home_id, home_last_game = params[:last_city_home].split("-").map(&:to_i)
      @last_city_home_team = Team.find_by(id: last_city_home_id)
      if @last_city_home_team != nil
        last_city_home_team_name = @last_city_home_team.team
        last_city_home_team_name = 'LAC' if last_city_home_team_name == 'LA Clippers'
        last_city_home_team_name = 'LAL' if last_city_home_team_name == 'LA Lakers'
        last_city_home_team_name = 'Oklahoma City' if last_city_home_team_name == 'Okla City'
        unless @games.empty?
          if home_last_game.nil?
            if @team_city[last_city_home_team_name]
              @games = @games.where("home_team_city = ?", @team_city[last_city_home_team_name]).or(@games.where("home_team_city = 'home' AND home_team = ?", last_city_home_team_name)).uniq
            else
              @games = @games.where("home_team_city = ?", last_city_home_team_name).or(@games.where("home_team_city = 'home' AND home_team = ?", last_city_home_team_name))
            end
          else
            if @team_city[last_city_home_team_name]
              @games = @games.where("home_team_city = ? AND home_last_game = ?", @team_city[last_city_home_team_name], home_last_game).or(@games.where("home_team_city = 'home' AND home_team = ? AND home_last_game = ?", last_city_home_team_name, home_last_game)).uniq
            else
              @games = @games.where("home_team_city = ? AND home_last_game = ?", last_city_home_team_name, home_last_game).or(@games.where("home_team_city = 'home' AND home_team = ? AND home_last_game = ?", last_city_home_team_name, home_last_game))
            end 
          end
        end
      end
    end

    if params[:last_city_away].present?
      @last_city_away = params[:last_city_away]
      last_city_away_id, away_last_game = params[:last_city_away].split("-").map(&:to_i)
      @last_city_away_team = Team.find_by(id: last_city_away_id)
      if @last_city_away_team != nil
        last_city_away_team_name = @last_city_away_team.team
        last_city_away_team_name = 'LAC' if last_city_away_team_name == 'LA Clippers'
        last_city_away_team_name = 'LAL' if last_city_away_team_name == 'LA Lakers'
        last_city_away_team_name = 'Oklahoma City' if last_city_away_team_name == 'Okla City'
        unless @games.empty?
          if away_last_game.nil?
            if @team_city[last_city_away_team_name]
              @games = @games.where("away_team_city = ?", @team_city[last_city_away_team_name]).or(@games.where("away_team_city = 'home' AND away_team = ?", last_city_away_team_name)).uniq
            else
              @games = @games.where("away_team_city = ?", last_city_away_team_name).or(@games.where("away_team_city = 'home' AND away_team = ?", last_city_away_team_name))
            end
          else
            if @team_city[last_city_away_team_name]
              @games = @games.where("away_team_city = ? AND away_last_game = ?", @team_city[last_city_away_team_name], away_last_game).or(@games.where("away_team_city = 'home' AND away_team = ? AND away_last_game = ?", last_city_away_team_name, away_last_game)).uniq
            else
              @games = @games.where("away_team_city = ? AND away_last_game = ?", last_city_away_team_name, away_last_game).or(@games.where("away_team_city = 'home' AND away_team = ? AND away_last_game = ?", last_city_away_team_name, away_last_game))
            end
          end
        end
      end
    end

    if params[:next_city_home].present?
      @next_city_home = params[:next_city_home]
      next_city_home_id, home_next_game = params[:next_city_home].split("-").map(&:to_i)
      @next_city_home_team = Team.find_by(id: next_city_home_id)
      if @next_city_home_team != nil
        next_city_home_team_name = @next_city_home_team.team
        next_city_home_team_name = 'LAC' if next_city_home_team_name == 'LA Clippers'
        next_city_home_team_name = 'LAL' if next_city_home_team_name == 'LA Lakers'
        next_city_home_team_name = 'Oklahoma City' if next_city_home_team_name == 'Okla City'
        unless @games.empty?
          if home_next_game.nil?
            if @team_city[next_city_home_team_name]
              @games = @games.where("home_team_next_city = ?", @team_city[next_city_home_team_name]).or(@games.where("home_team_next_city = 'home' AND home_team = ?", next_city_home_team_name)).uniq
            else
              @games = @games.where("home_team_next_city = ?", next_city_home_team_name).or(@games.where("home_team_next_city = 'home' AND home_team = ?", next_city_home_team_name))
            end
          else
            if @team_city[next_city_home_team_name]
              @games = @games.where("home_team_next_city = ? AND home_next_game = ?", @team_city[next_city_home_team_name], home_next_game).or(@games.where("home_team_next_city = 'home' AND home_team = ? AND home_next_game = ?", next_city_home_team_name, home_next_game)).uniq
            else
              @games = @games.where("home_team_next_city = ? AND home_next_game = ?", next_city_home_team_name, home_next_game).or(@games.where("home_team_next_city = 'home' AND home_team = ? AND home_next_game = ?", next_city_home_team_name, home_next_game))
            end
          end
        end
      end
    end

    if params[:next_city_away].present?
      @next_city_away = params[:next_city_away]
      next_city_away_id, away_next_game = params[:next_city_away].split("-").map(&:to_i)
      @next_city_away_team = Team.find_by(id: next_city_away_id)
      if @next_city_away_team != nil
        next_city_away_team_name = @next_city_away_team.team
        next_city_away_team_name = 'LAC' if next_city_away_team_name == 'LA Clippers'
        next_city_away_team_name = 'LAL' if next_city_away_team_name == 'LA Lakers'
        next_city_away_team_name = 'Oklahoma City' if next_city_away_team_name == 'Okla City'
        unless @games.empty?
          if away_next_game.nil?
            if @team_city[next_city_away_team_name]
              @games = @games.where("away_team_next_city = ?", @team_city[next_city_away_team_name]).or(@games.where("away_team_next_city = 'home' AND away_team = ?", next_city_away_team_name)).uniq
            else
              @games = @games.where("away_team_next_city = ?", next_city_away_team_name).or(@games.where("away_team_next_city = 'home' AND away_team = ?", next_city_away_team_name))
            end
          else
            if @team_city[next_city_away_team_name]
              @games = @games.where("away_team_next_city = ? AND away_next_game = ?", @team_city[next_city_away_team_name], away_next_game).or(@games.where("away_team_next_city = 'home' AND away_team = ? AND away_next_game = ?", next_city_away_team_name, away_next_game)).uniq
            else
              @games = @games.where("away_team_next_city = ? AND away_next_game = ?", next_city_away_team_name, away_next_game).or(@games.where("away_team_next_city = 'home' AND away_team = ? AND away_next_game = ?", next_city_away_team_name, away_next_game))
            end
          end
        end
      end
    end
  end
end