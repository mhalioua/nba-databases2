module Api
	def mechanize_page(url)
		page = nil
		count = 3
		begin
			if count > 0
				count -= 1
				Timeout::timeout(3){
					page = Mechanize.new.get(url)
				}
			end
		rescue => e
			retry
		end	
		return page
	end
	
	def download_document(url)
		require 'open-uri'
		doc = nil
		count = 3
		begin
			if count > 0
				count -= 1
				Timeout::timeout(10){
					doc = Nokogiri::HTML(open(url, allow_redirections: :all))
				}
			end
		rescue => e
			retry
		end
		return doc
	end
end