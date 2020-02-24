class DataSheetController < ApplicationController
	def get_data_sheet
		if params[:email]
			begin
   				AdminMailer.send_nba_data(params[:email]).deliver_now!
   			rescue Exception => e
   				flash[:notice] = "Something went wrong!!!"
   			end
			flash[:notice] = "File sent"
		end
	end

end
