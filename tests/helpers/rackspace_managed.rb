# Include helper objects and methods.
require_helper "errors"

# Setup the credentials required for Rackspace Managed Open Cloud as advanced
# inputs.
#
# @param server [Server] the server to check
#
def setup_rackspace_managed_credentials(server)
  server.set_inputs(
    "rightscale/rackspace_api_key" => "cred:RACKSPACE_RACKMANAGED_API_KEY",
    "rightscale/rackspace_tenant_id" => "cred:RACKSPACE_RACKMANAGED_TENANT_ID",
    "rightscale/rackspace_username" => "cred:RACKSPACE_RACKMANAGED_USERNAME"
  )
end

# Verify that the Rackspace Managed Open Cloud agents are running properly.
#
# @param server [Server] the server to check
#
# @raise [RackspaceRackManagedError] if the rackspace agents are not running
#   properly.
#
def verify_rackspace_managed_agents(server)
  rackspace_agents = ["driveclient", "rackspace-monitoring-agent"]
  # Verify the agents functionality on all servers
  rackspace_agents.each do |agent|
    probe(server, "service #{agent} status") do |response, status|
      unless status == 0
        raise FailedProbeCommandError, "Unable to verify that #{agent} is" +
          " running on #{server.nickname}. status code: #{status}." +
          " response: #{response}"
      end
      if response.include?("running")
        puts "The #{agent} agent is running on #{server.nickname}"
      else
        raise RackspaceRackManagedError, "The #{agent} agent is not running" +
          " on #{server.nickname}. Current status is #{response}"
      end
      true
    end
  end
end
