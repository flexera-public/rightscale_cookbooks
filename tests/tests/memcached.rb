# Include helper objects and methods.
require_helper "errors"
require_helper "monitoring"

# Require generic ruby libraries and gems.
require 'net/telnet'

# Test specific helpers.
#
helpers do
  # An error such as Connection Refused or Connection Timeout while
  # communicating with Memcached server.
  #
  class MemcachedConnectionError < VirtualMonkey::TestCase::ErrorBase
  end
end

# When rerunning a test, shutdown all of the servers.
#
hard_reset do
#  stop_all
end

# Before all of the test cases, launch all of the servers in the deployment.
#
before do
  launch_all
  wait_for_all("operational")
end

# The smoke test for Memcached ServerTemplate makes sure that the memcached is
# functioning properly by sending and receiving a cache string. It also
# verifies that the monitoring plugin for memcached is operational.
#
test_case "smoke test" do
  # Single server in deployment.
  server = servers.first

  # Making a telnet connection to the memcached server
  # Be sure of using a reachable ip and an open port
  memcached_server = server.reachable_ip
  begin
    connection = Net::Telnet.new("Host" => memcached_server, "Port" => 11211)
    puts "Telnet connection successful to #{memcached_server}, getting stats."

    # Getting stats from the Memcached Server
    result = connection.cmd("String" => "stats", "Match" => /^END/)
    puts "Stats obtained: #{result}"
    puts "Stats received. Now checking caching..."
    cache_string = "All work and no play makes Jack a dull boy."
    puts "Sending \"#{cache_string}\" to the server."

    # Sending the cache string to the server using "set" and verifying the
    # reception of the string by using "get".
    connection.cmd(
      "String" => "set name 0 60 43\n#{cache_string}",
      "Match" => /^STORED/
    )
    puts "Receiving cached string."
    # Receiving string via get
    result = connection.cmd("String" => "get name", "Match" => /^END/)
    if result =~ /#{cache_string}/
      puts "Memcached test completed successfully."
    else
      raise MemcachedConnectionError, "The server didn't receive the cache" +
        " string properly. Stats received from the server: #{result}"
    end
  rescue Errno::ECONNREFUSED
    raise MemcachedConnectionError, "Could not telnet to memcached server!"
  rescue Timeout::Error
    raise MemcachedConnectionError, "Timed out connecting to memcached server!"
  ensure
    connection.close
  end

  # Verify the monitoring of the memcached plugin
  check_monitoring(server, "memcached", "memcached_command-get")
end
