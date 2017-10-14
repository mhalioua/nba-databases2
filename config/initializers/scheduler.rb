require 'rufus-scheduler'
scheduler = Rufus::Scheduler::singleton

scheduler.every '10s' do
	system("rake setup:tensecond")
end