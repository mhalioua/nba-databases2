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
  end
end