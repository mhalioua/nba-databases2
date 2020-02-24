class AdminMailer < ActionMailer::Base
  default from: "no-reply@nbadatabases.com"

  require 'net/http'
  require 'stringio'

  def send_nba_data(email)
  	#@att = export_file_path
  	#@att = "https://nba-databases.herokuapp.com/exports/nba_databases_data.xls"
  	#attachments["nba_data.xls"] = File.read(export_file_path)
  	@att = "https://nba-daemon.s3.amazonaws.com/nba_data/nba_data_sheet.xls"
    mail(:to => email, subject: "NBA Data")
  end
end