class WelcomeController < ApplicationController
	
	before_action :confirm_logged_in

	def index
	  	unless params[:id]
	  	  	params[:id] = Time.now.strftime("%Y-%m-%d")
	  	end
	  	@game_index = params[:id]
	  	@games = Game.where("game_date between ? and ?", Date.strptime(@game_index).beginning_of_day, Date.strptime(@game_index).end_of_day)
	  				.order("game_state")
	  				.order("game_status")
	  				.order("game_date")
	end
end
