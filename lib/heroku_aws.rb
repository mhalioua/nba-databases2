
#file = Tempfile.new(["sample_imgkit", 'png'], 'tmp')
#file.write(IMGKit.new("https://nba-databases.herokuapp.com/index/rest_view/401161364", quality: 50, width: 600))
#s3 = Aws::S3::Resource.new(
	#  credentials: Aws::Credentials.new('AKIAJIZM3ZYYLD26RKYQ', 'hHclrysbWdDDBED90zzybO/3H2envpFBd7iUdvQk'),
#	  region: 'us-east-1',
	#  endpoint:'https://s3.us-east-1.amazonaws.com'
	#)
	class HerokuAws
		games = Nba.all
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