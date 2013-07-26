#!/usr/bin/ruby
#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

require "rubygems"
require "getoptlong"

def usage
  puts "#{$0} -h <hostname> [-i <sample_interval>]"
  puts "    -h: The hostname of the machine. When using RightLink," +
    " use the SERVER UUID."
  puts "    -i: The sample interval of the file check (in seconds)." +
    " Default: 20 seconds"
  exit
end


opts = GetoptLong.new(
  [ "--hostname", "-h", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--sample-interval", "-i",  GetoptLong::OPTIONAL_ARGUMENT ]
)

# Default values
hostname = nil
sample_interval = 20

# Check for updates every hour
update_check_freq = 3600

# Timestamp of last check
last_update_check = 0

opts.each do |opt, arg|
  case opt
  when "--hostname"
    hostname = arg
  when "--sample-interval"
    sample_interval = arg.to_i
  end
  arg.inspect
end

usage unless hostname

# Initialize the packages count
security_packages = 0
regular_packages = 0

loop do
  now = Time.now.to_i
  if (now - last_update_check) > update_check_freq
    # List all available updates and count the number of lines and get rid of
    # the line that says "Updated packages"
    regular_packages =
      `yum list --quiet --cacheonly updates 2>/dev/null | wc -l`.to_i - 1
    # There is no line saying "Updated package" if there are no updates
    regular_packages = 0 if regular_packages < 0
    security_packages =
      `yum list-security security --quiet --cacheonly 2>/dev/null | wc -l`.to_i

    # Tag the server if updates are available.
    if security_packages > 0
      system(
        "rs_tag --add 'rs_monitoring:security_updates_available=true' >" +
          " /dev/null 2>&1"
      )
    else
      system(
        "rs_tag --remove 'rs_monitoring:security_updates_available=true' >" +
          " /dev/null 2>&1"
      )
    end
    last_update_check = now
  end

  puts "PUTVAL #{hostname}/update_check/gauge-pending_updates" +
    " interval=#{sample_interval} #{now}:#{regular_packages}\n"
  puts "PUTVAL #{hostname}/update_check/gauge-pending_security_updates" +
    " interval=#{sample_interval} #{now}:#{security_packages}\n"

  STDOUT.flush
  sleep sample_interval
end
