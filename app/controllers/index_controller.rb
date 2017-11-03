class IndexController < ApplicationController
	before_action :confirm_logged_in
	def home
		@yesterday = Time.now - 1.days
    	@today = Time.now
    	@tomorrow = Time.now + 1.days
  	end

	def game
	  	unless params[:id]
	  	  	params[:id] = Time.now.strftime("%Y%m%d")
	  	end
		@game_index = params[:id]

  		@head = Date.strptime(@game_index, '%Y%m%d').strftime("%B %e")
  		@prev = (Date.strptime(@game_index, '%Y%m%d') - 1.days).strftime("%Y%m%d")
  		@next = (Date.strptime(@game_index, '%Y%m%d') + 1.days).strftime("%Y%m%d")
		@games = Nba.where("game_date between ? and ?", Date.strptime(@game_index, '%Y%m%d').beginning_of_day, Date.strptime(@game_index, '%Y%m%d').end_of_day)
	  				.order("game_date")
	end

	def detail
		@game_id = params[:id]
		@game = Nba.find_by(game_id: @game_id)
		@head = @game.home_team + " @ " + @game.away_team
		
		@home_abbr = @game.home_abbr
		@away_abbr = @game.away_abbr

		@now = Date.strptime(@game.game_date)
		if @now > Time.now
			@now = Time.now
		end

		@away_last = Nba.where("home_abbr = ? AND game_date < ?", @away_abbr, @now).or(Nba.where("away_abbr = ? AND game_date < ?", @away_abbr, @now)).order(:game_date).last
		@home_last = Nba.where("home_abbr = ? AND game_date < ?", @home_abbr, @now).or(Nba.where("away_abbr = ? AND game_date < ?", @home_abbr, @now)).order(:game_date).last
		
		if @away_abbr == @away_last.away_abbr
			@away_players = @away_last.players.where('team_abbr = 0')
		else
			@away_players = @away_last.players.where('team_abbr = 1')
		end

		if @home_abbr == @home_last.away_abbr
			@away_players = @home_last.players.where('team_abbr = 0')
		else
			@away_players = @home_last.players.where('team_abbr = 1')
		end
		@date_id = Date.strptime(@game.game_date).strftime("%Y%m%d")
	end
end
