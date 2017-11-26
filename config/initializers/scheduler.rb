require 'rufus-scheduler'
scheduler = Rufus::Scheduler::singleton

scheduler.every '1m' do
	system("rake nba:getHalf")
end