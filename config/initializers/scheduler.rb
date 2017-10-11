require 'rufus-scheduler'

scheduler = Rufus::Scheduler::singleton

s.every '1m' do
  Rails.logger.info "hello, it's #{Time.now}"
end