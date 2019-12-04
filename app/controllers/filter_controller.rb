class FilterController < ApplicationController
  def index
    @teams = Team.all.order('team')
  end

  def show
    id = params[:id]
    @team = Team.find_by(id: id)
    @games = Nba.where("home_team = ? AND game_date < ? AND id >= 26796", @team.team, Date.current)
               .or(Nba.where("home_team = ? AND game_date < ? AND id <= 26573 AND id >= 25261", @team.team, Date.current)).order('id DESC').limit(100)
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
      @games = @games.where("game_date < ?", Date.current)
    else
      @games = @games.where("game_date between ? and ?", Date.strptime(@game_start_index, '%b %d, %Y').beginning_of_day, Date.strptime(@game_end_index, '%b %d, %Y').end_of_day)
    end
    @teams = Team.all.order('team')
    @home_team_id = 0
    @away_team_id = 0
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
  end
end