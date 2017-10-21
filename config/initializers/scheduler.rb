require 'rufus-scheduler'
scheduler = Rufus::Scheduler::singleton

scheduler.every '30s' do
	system("rake setup:tensecond")
end