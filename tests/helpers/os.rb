# Include helper objects and methods.
require_helper "errors"

# Returns the operating system type for an operational server.
#
# @param server [Server] the server to get operating system type
#
# @raise [FailedProbeCommandError] if the get operating system probe fails
#
# @return [String] Operating system type: "CentOS", "Ubuntu", "RHEL", etc. 
#
def get_operating_system(server)
  @@operating_systems ||= {}
  unless @@operating_systems[server]
    probe(server, "lsb_release -si") do |response, status|
      raise FailedProbeCommandError, "System call to get OS failed" unless 
        status == 0
      @@operating_systems[server] = response.chomp
      true
    end
  end
  puts "Found OS type: #{@@operating_systems[server]}"
  @@operating_systems[server]
end

# Returns the syslog file path based on the operating system in the server.
#
# @param server [Server] the server to get the syslog file path
#
# @return [String] the syslog file path
#
def get_syslog_file(server)
  case get_operating_system(server)
  when /ubuntu/i
    "/var/log/syslog"
  else
    "/var/log/messages"
  end
end
