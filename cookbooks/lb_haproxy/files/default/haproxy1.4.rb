#!/usr/bin/env ruby
# 
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.


# HAProxy 1.3.14+ collectd plugin.
# Requires using 'stats socket <path> [{uid | user} <uid>] [{gid | group} <gid>] [mode <mode>]'
# options of HAProxy 1.3.14+

require 'optparse'
require 'socket'

HAPROXY_SOCKET="/etc/haproxy/status"
HAPROXY_COMMAND="show stat\n"

@status = {
  :UP => 2, # Server is actively up.
  :DOWN => -2, # Server is actively down.
  :GOINGDOWN => -1, # Server up but going down. Haproxy returns UP x/y.
  :GOINGUP => 1, # Server down but going up. Haproxy returns DOWN x/y.
  :NOCHECK => 0, # not checked. Haproxy returns "no check".
  :NOLB => 0 # Up with load balancing disabled. Haproxy returns "NOLB".
}

# Defaults if arguments passed.
@options = {
  :socket => "/etc/haproxy/status",
  :instanceid => ENV['EC2_INSTANCE_ID'],
  :interval => 20
}


def usage(code = 0)
  out = "\n" + $0.split(' ')[0] + " usage:\n"
  out << "\e[1mDESCRIPTION\e[0m\n"
  out << "\tThis collectd exec plugin is intended to collect the statistic\n"
  out << "\treport from HAporxy. It then parses the returned counters and\n"
  out << "\tfeeds them into collectd.\n"
  out << "\t-d, --hostid \e[1;4mINSTANCE ID\e[0m\n"
  out << "\t\tThe instance id of which the data is being collected\n"
  out << "\t-s, --socket UNIX SOCKET\n"
  out << "\t\tthe unix socket descriptor location (/etc/haproxy/status)\n"
  out << "\t-n, --sampling-interval \e[1;4mINTERVAL\e[0m\n"
  out << "\t\tThe interval (in second) between each sampling.\n"
  out << "\t-h, --help\n\n"
  puts "\n" + out
  Kernel.exit(code)
end


# Read stats from socket as CSV values.
def readstats
  results = []
  client = UNIXSocket.open(@options[:socket])
  client.send(HAPROXY_COMMAND, 0)
  results << client.readline until client.eof?
  results
rescue Exception => e
  puts "Socket Error: #{e}"
  exit 1
end

# Parse CSV results & build hash of data based on server name.
def parsestats
  column = []
  stats = []

  readstats.each do |line|
    stat = {}
    # Match for column header line.
    if line.match(/# /)
      line.slice!(/# /)
      column = line.split(/,/)
    else
      # Grab values
      value = line.split(/,/)
      column.each_index do |id|
        # Sometimes haproxy1.4 has empty lines, skip them.
        stat[column[id].to_sym] = value[id] if value[id]
      end
    end

    # Convert text description of server status into numeric value for graphs.
    # Only change nocheck, up x/y, down x/y - convert the rest to uppercase.
    stat[:status] = case stat[:status].to_s.downcase
                    when /no check/
                      "NOCHECK"
                    when /up \d+\/\d+/
                      "GOINGDOWN"
                    when /down \d+\/\d+/
                      "GOINGUP"
                    else
                      stat[:status].to_s.upcase
                    end

    # Append the hash to a list, so each line is processed.
    stats << stat if stat[:svname]
  end
  stats
end

# Output data into an collectd EXEC plugin compatible format.
# Prints totals from backend instance then. Prints data for individual instances.
def outputstats(now)

  hostname = @options[:instanceid]
  results = parsestats

  results.each { |h|

    if h[:svname] == "BACKEND"
      puts "PUTVAL #{hostname}/haproxy-#{h[:pxname]}/haproxy_sessions-total #{now}:#{h[:qcur]}:#{h[:scur]}"
      puts "PUTVAL #{hostname}/haproxy-#{h[:pxname]}/haproxy_traffic-total #{now}:#{h[:stot]}:#{h[:eresp]}:0"
    end

    unless h[:svname].match(/(FRONT|BACK)END/)
      server_name = h[:svname].gsub(/-/, '_').downcase
      puts "PUTVAL #{hostname}/haproxy-#{h[:pxname]}/haproxy_sessions-#{server_name} #{now}:#{h[:qcur]}:#{h[:scur]}"
      puts "PUTVAL #{hostname}/haproxy-#{h[:pxname]}/haproxy_traffic-#{server_name} #{now}:#{h[:stot]}:#{h[:eresp]}:#{h[:chkfail]}"
      puts "PUTVAL #{hostname}/haproxy-#{h[:pxname]}/haproxy_status-#{server_name} #{now}:#{@status[h[:status].to_sym]}"
    end
  }

end

# Parse arguments.
opts = OptionParser.new
opts.banner = "Usage: haproxy.rb"
opts.on("-d ID", "--hostid ID") { |str| @options[:instanceid] = str }
opts.on("-n INTERVAL", "--sampling-interval INTERVAL") { |str| @options[:interval] = str }
opts.on("-s UNIX-SOCKET", "--socket") { |str| @options[:socket] = str }

begin
  opts.parse(ARGV)
rescue Exception => e
  usage(-1)
end

# Main loop to handle timing.
begin

  $stdout.sync = true

  while true do
    last_run = Time.now.to_i
    next_run = last_run + @options[:interval].to_i

    now = Time.now.to_i
    outputstats(now)
    while (time_left = (next_run - Time.now.to_i)) > 0 do
      sleep(time_left)
    end
  end

end
