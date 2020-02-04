	class HerokuAws
		def self.heroku_upload_images(games)
			games.each do |game|
				if game.filters.any?
					kit = IMGKit.new("https://nba-databases.herokuapp.com/index/rest_view/#{game.game_id}")
					file = kit.to_file("#{Rails.root}/tmp/rest_view.png")
					obj = S3.object("imgaes_new/#{game.game_id}.png")
					obj.upload_file(file, acl:'public-read')
					File.delete(file)
				end
			end
		end
	end