class DataSheetController < ApplicationController
	def get_data_sheet
		if params[:email]
			begin
   				AdminMailer.send_nba_data(params[:email]).deliver_now!
   			rescue Exception => e
   				flash.now[:notice] = "Something went wrong!!!"
   			end
			flash.now[:notice] = "File sent"
		end
	end

end
