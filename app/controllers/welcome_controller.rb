class WelcomeController < ApplicationController
	def index
	  	unless params[:id]
	  	  	params[:id] = Time.now.strftime("%Y-%m-%d")
	  	end
	  	@game_index = params[:id]
	  	@games = Game.all
	  	@week_dropdown = []
		@games.each do |game|
			if game.game_date.to_s != ""
				@week_dropdown << [game.game_date.to_formatted_s(:iso8601)[0..9], game.game_date.to_formatted_s(:iso8601)[0..9]]
			end
		end
		@week_dropdown << [Time.now.strftime("%Y-%m-%d"), Time.now.strftime("%Y-%m-%d")]
		@week_dropdown = @week_dropdown.uniq
		@week_dropdown = @week_dropdown.sort
	  	@games = Game.where("game_date between ? and ?", Date.strptime(@game_index).beginning_of_day, Date.strptime(@game_index).end_of_day)
	  				.order("game_state")
	  				.order("game_status")
	  				.order("game_date")
	end
end
