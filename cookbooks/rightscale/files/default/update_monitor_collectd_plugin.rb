#!/usr/bin/ruby

require 'rubygems'
require 'getoptlong'

def usage
  puts("#{$0} -h <hostname> [-i <sample_interval>]")
  puts("    -h: The hostname of the machine. When using RightLink, use the SERVER UUID.")
  puts("    -i: The sample interval of the file check (in seconds).  Default: 20 seconds")
  exit
end


opts = GetoptLong.new(
            [ '--hostname', '-h', GetoptLong::REQUIRED_ARGUMENT ],
            [ '--sample-interval', '-i',  GetoptLong::OPTIONAL_ARGUMENT ]
)

# default values
hostname = nil
sample_interval = 20

# check for updates every hour
update_check_freq = 3600

# timestamp of last check
last_update_check = 0

## path to apt-check
#apt_check="/usr/lib/update-notifier/apt-check"
# Replace with yum check of some kind


opts.each do |opt, arg|
  case opt
    when '--hostname'
      hostname = arg
    when '--sample-interval'
      sample_interval = arg.to_i
  end
  arg.inspect
end

usage if !hostname

packages_to_update=Array.new(0,0)

loop do
  now = Time.now

  if ( now.to_i - last_update_check ) > update_check_freq
    # List all available updates and count the number of lines and get rid of
    # the line that says "Updated packages"
    packages_to_update[0] = `yum list -q updates 2>&1 | wc -l`.to_i  -1
    packages_to_update[1] = `yum list-security -q 2>&1 | wc -l`

    # Tag the server if updates are available.
    if (packages_to_update[1].to_i > 0) then
      system("rs_tag -a 'security_updates_available' > /dev/null 2>&1")
    else
      system("rs_tag -r 'security_updates_available' > /dev/null 2>&1")
    end

    last_update_check = now.to_i
  end

  puts "PUTVAL #{hostname}/update_check/gauge-pending_updates interval=#{sample_interval} #{now.to_i}:#{packages_to_update[0]}\n"
  puts "PUTVAL #{hostname}/update_check/gauge-pending_security_updates interval=#{sample_interval} #{now.to_i}:#{packages_to_update[1]}\n"

  STDOUT.flush
  sleep sample_interval
end


