# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 24.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
every 24.hours do
  runner "History.delete_all"
  runner "History.resetIdSeq"

  runner "AbnormalName.delete_all"
  runner "AbnormalName.resetIdSeq"

  runner "DomainCache.delete_all"
  runner "DomainCache.resetIdSeq"



end