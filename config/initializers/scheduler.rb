require 'rufus-scheduler'

scheduler = Rufus::Scheduler::singleton

scheduler.every '10s' do
	Rake::Task["setup:tensecond"].invoke
	Rake::Task["setup:tensecond"].reenable
end