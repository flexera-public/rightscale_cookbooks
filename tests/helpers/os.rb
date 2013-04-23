# Include helper objects and methods.
require_helper "errors"

# Returns the operating system type for an operatinal server.
#
# @param server [Server] the server to get operating system type.
#
# @raise [FailedProbeCommandError] if the get operating system probe fails.
#
# @return [String] Operating system type: "CentOS", "ubuntu", "RHEL", etc. 
#
def get_operating_system(server)
  os = ""
  probe(server, "lsb_release -si") do |response, status|
    raise FailedProbeCommandError, "System call to get OS failed" unless 
      status == 0
    os = response.chomp
    true
  end
  puts "Found OS type: #{os}"
  os
end
