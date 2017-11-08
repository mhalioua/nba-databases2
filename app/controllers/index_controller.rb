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
			@away_players = @away_last.players.where('team_abbr = 0').order(:state)
		else
			@away_players = @away_last.players.where('team_abbr = 1').order(:state)
		end
		@away_players = @away_players[0..-2]

		if @home_abbr == @home_last.away_abbr
			@home_players = @home_last.players.where('team_abbr = 0').order(:state)
		else
			@home_players = @home_last.players.where('team_abbr = 1').order(:state)
		end
		@home_players = @home_players[0..-2]
		@date_id = Date.strptime(@game.game_date).strftime("%Y%m%d")

	    @away_total_poss = 0
	    @away_total_min = 0
	    @away_total_prorate = 100
	    @away_players.each_with_index do |player, index| 
	        @away_total_poss = @away_total_poss + (100 * player.sum_poss.to_f/player.team_poss)
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count
	        end
	        @away_total_min = @away_total_min + player.sum_mins/count
	    end

	    @away_players.each_with_index do |player, index| 
	    	player.prorate = player.poss / total_poss
	    end

	    @home_total_poss = 0
	    @home_total_min = 0
	    @home_total_prorate = 100
	    @home_players.each_with_index do |player, index| 
	        @home_total_poss = @home_total_poss + (100 * player.sum_poss.to_f/player.team_poss)
	        count = 1
	        if player.possession
	          	count = player.possession.scan(/,/).count
	        end
	        @home_total_min = @home_total_min + player.sum_mins/count
	    end

	    @home_players.each_with_index do |player, index| 
	    	player.prorate = player.poss / total_poss
	    end
	end
end
