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
    unless params[:date]
      params[:date] = Time.now.strftime("%b %d, %Y") + " - " + Time.now.strftime("%b %d, %Y")
    end
    @game_index = params[:date]
    @game_start_index = @game_index[0..12]
    @game_end_index = @game_index[15..27]

    @games = Nba.where("game_date between ? and ? AND id >= 26796", Date.strptime(@game_start_index, '%b %d, %Y').beginning_of_day, Date.strptime(@game_end_index, '%b %d, %Y').end_of_day)
               .or(Nba.where("game_date between ? and ? AND id <= 26573 AND id >= 25261", Date.strptime(@game_start_index, '%b %d, %Y').beginning_of_day, Date.strptime(@game_end_index, '%b %d, %Y').end_of_day)).order('id DESC')

    @teams = Team.all.order('team')
    @home_team_id = 0
    @away_team_id = 0
    if params[:home_team_id].present?
      @home_team_id = params[:home_team_id]
      @home_team = Team.find_by(id: params[:home_team_id])
      @games = @games.where("home_team = ?", @home_team.team) if @home_team != nil
    end

    if params[:away_team_id].present?
      @away_team_id = params[:away_team_id]
      @away_team = Team.find_by(id: params[:away_team_id])
      @games = @games.where("away_team = ?", @away_team.team) if @away_team != nil
    end
  end
end