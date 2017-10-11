require 'rufus-scheduler'

scheduler = Rufus::Scheduler::singleton


scheduler.every '5s' do
  # do stuff
  User.create(name: "a", password: "a", password_confirmation: "a")
end