require 'rufus-scheduler'
scheduler = Rufus::Scheduler::singleton

scheduler.every '3m' do
	system("rake nba:getHalf")
end