require 'rufus-scheduler'

scheduler = Rufus::Scheduler::singleton

scheduler.every '10s' do
	rake "setup:tensecond"
end