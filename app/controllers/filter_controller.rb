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

    @games = Nba.where("id >= 26796").or(Nba.where("id <= 26573 AND id >= 25261")).order('id DESC')

    if @datePicker
      @games = @games.where("game_date <= ?", Date.today.end_of_day)
    else
      @games = @games.where("game_date between ? and ?", Date.strptime(@game_start_index, '%b %d, %Y').beginning_of_day, Date.strptime(@game_end_index, '%b %d, %Y').end_of_day)
    end
    @teams = Team.all.order('team')
    @home_team_id = 0
    @away_team_id = 0
    @last_city_home = 0
    @last_city_away = 0
    @next_city_home = 0
    @next_city_away = 0
    if params[:home_team_id].present?
      @home_team_id = params[:home_team_id].to_i
      @home_team = Team.find_by(id: params[:home_team_id])
      if @home_team != nil
        home_team_name = @home_team.team
        home_team_name = 'LAC' if home_team_name == 'LA Clippers'
        home_team_name = 'LAL' if home_team_name == 'LA Lakers'
        @games = @games.where("home_team = ?", home_team_name)
      end
    end

    if params[:away_team_id].present?
      @away_team_id = params[:away_team_id].to_i
      @away_team = Team.find_by(id: params[:away_team_id])
      if @away_team != nil
        away_team_name = @away_team.team
        away_team_name = 'LAC' if away_team_name == 'LA Clippers'
        away_team_name = 'LAL' if away_team_name == 'LA Lakers'
        @games = @games.where("away_team = ?", away_team_name)
      end
    end

    if params[:last_city_home].present?
      @last_city_home = params[:last_city_home].to_i
      @last_city_home_team = Team.find_by(id: params[:last_city_home])
      if @last_city_home_team != nil
        last_city_home_team_name = @last_city_home_team.team
        last_city_home_team_name = 'LAC' if last_city_home_team_name == 'LA Clippers'
        last_city_home_team_name = 'LAL' if last_city_home_team_name == 'LA Lakers'
        last_city_home_team_name = 'Oklahoma City' if last_city_home_team_name == 'Okla City'
        @games = @games.where("home_team_city = ?", last_city_home_team_name).or(@games.where("home_team_city = 'home' AND home_team = ?", last_city_home_team_name))
      end
    end

    if params[:last_city_away].present?
      @last_city_away = params[:last_city_away].to_i
      @last_city_away_team = Team.find_by(id: params[:last_city_away])
      if @last_city_away_team != nil
        last_city_away_team_name = @last_city_away_team.team
        last_city_away_team_name = 'LAC' if last_city_away_team_name == 'LA Clippers'
        last_city_away_team_name = 'LAL' if last_city_away_team_name == 'LA Lakers'
        last_city_away_team_name = 'Oklahoma City' if last_city_away_team_name == 'Okla City'
        @games = @games.where("away_team_city = ?", last_city_away_team_name).or(@games.where("away_team_city = 'home' AND away_team = ?", last_city_away_team_name))
      end
    end

    if params[:next_city_home].present?
      @next_city_home = params[:next_city_home].to_i
      @next_city_home_team = Team.find_by(id: params[:next_city_home])
      if @next_city_home_team != nil
        next_city_home_team_name = @next_city_home_team.team
        next_city_home_team_name = 'LAC' if next_city_home_team_name == 'LA Clippers'
        next_city_home_team_name = 'LAL' if next_city_home_team_name == 'LA Lakers'
        next_city_home_team_name = 'Oklahoma City' if next_city_home_team_name == 'Okla City'
        @games = @games.where("home_team_next_city = ?", next_city_home_team_name).or(@games.where("home_team_next_city = 'home' AND home_team = ?", next_city_home_team_name))
      end
    end

    if params[:next_city_away].present?
      @next_city_away = params[:next_city_away].to_i
      @next_city_away_team = Team.find_by(id: params[:next_city_away])
      if @next_city_away_team != nil
        next_city_away_team_name = @next_city_away_team.team
        next_city_away_team_name = 'LAC' if next_city_away_team_name == 'LA Clippers'
        next_city_away_team_name = 'LAL' if next_city_away_team_name == 'LA Lakers'
        next_city_away_team_name = 'Oklahoma City' if next_city_away_team_name == 'Okla City'
        @games = @games.where("away_team_next_city = ?", next_city_away_team_name).or(@games.where("away_team_next_city = 'home' AND away_team = ?", next_city_away_team_name))
      end
    end
  end
end