	class HerokuAws
		def self.heroku_upload_images
		game_start_index = '2016-01-01'
	    game_end_index = (Date.today).to_s
	    games = Nba.where("game_date between ? and ?", Date.strptime(game_start_index).beginning_of_day, Date.strptime(game_end_index).end_of_day)
	    
			games.each do |game|
				puts "*"*20
      			puts game.id
				url = URI.parse("https://nba-daemon.s3.amazonaws.com/imgaes_new/#{game.game_id}.png")
			    http = Net::HTTP.new(url.host, url.port)
			    http.use_ssl = true if url.scheme == 'https'
			    unless http.request_head(url.path).code == "200"
					kit = IMGKit.new("https://nba-databases.herokuapp.com/index/rest_view/#{game.game_id}", :quality => 50)
					file = kit.to_file("#{Rails.root}/tmp/rest_view#{game.game_id}.png")
					obj = S3.object("imgaes_new/#{game.game_id}.png")
					obj.upload_file(file, acl:'public-read')
					File.delete(file)
				end
				puts "*"*200 
                puts "finished"
			end
		end
	end