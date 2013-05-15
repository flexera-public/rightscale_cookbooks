# Include the helper objects and methods.
require_helper "cloud"
require_helper "ephemeral"
require_helper "wait_for_ip_repopulation"
require_helper "errors"
require_helper "os"
require_helper "input"

# Test specific helpers.
#
helpers do
  # An error with swap file setup.
  #
  class SwapFileError < VirtualMonkey::TestCase::ErrorBase
  end

  # An error with conntrack_max setup.
  #
  class ConntrackMaxError < VirtualMonkey::TestCase::ErrorBase
  end

  # An error with Rackspace Managed agents not running properly.
  #
  class RackspaceManagedError < VirtualMonkey::TestCase::ErrorBase
  end

  # An error with unfrozen repo check
  #
  class FrozenRepoError < VirtualMonkey::TestCase::ErrorBase
  end

  # Checks if the swap file is set up.
  #
  # @param server [Server] the server to check
  #
  # @raise [SwapFileError] if the swap file is not set up
  #
  def check_swap_file(server)
    # Get location of swap file from ServerTemplate input.
    swapfile = get_input_from_server(server)["sys/swap_file"].split("text:")[1]

    # SSH to the server and see if the swap file path is in the swap devices
    # list.
    #
    probe(servers.first, "grep -c #{swapfile} /proc/swaps") do |result, status|
      puts "Swapfile: #{result.inspect}"
      raise SwapFileError, "swap file not setup correctly" unless ((result).to_i > 0)
      true
    end
  end

  # Checks if this test is running against a Chef ServerTemplate or an RSB
  # ServerTemplate.
  #
  # @return [Boolean] whether the test is running against a Chef ServerTemplate
  #
  def is_chef?
    suite_variables[:server_template_type] == "chef"
  end

  # Obtains the conntrack_max value from /etc/sysctl.conf configuration file
  #
  # @param server [Server] the server to obtain value from
  #
  # @return [String] conntrack_max value from configuration file
  #
  # @raise [FailedProbeCommandError] if probe fails to obtain conntrack_max value from
  #   configuration file
  #
  def obtain_conf_conntrack_max(server)
    conntrack_module_name = "net.netfilter.nf_conntrack_max"
    conf_conntrack_max = ""
    # SSH to the server and obtain the conntrack_max value from
    # /etc/sysctl.conf file
    probe(server,
      %Q{sh -c "grep "#{conntrack_module_name}" /etc/sysctl.conf"}) do |result, status|
      raise FailedProbeCommandError, "Can't probe the server to obtain conntrack_max value from /etc/sysctl.conf" unless status == 0
      puts "conntrack_max value in /etc/sysctl.conf: #{result}"
      conf_conntrack_max = result
      true
    end
    conf_conntrack_max
  end

  # Obtains the conntrack_max value using sysctl command
  #
  # @param server [Server] the server to obtain value from
  #
  # @return [String] conntrack_max value from sysctl commann
  #
  # @raise [FailedProbeCommandError] if probe fails to obtain conntrack_max value from
  #   sysctl command
  #
  def obtain_sysctl_conntrack_max(server)
    conntrack_module_name = "net.netfilter.nf_conntrack_max"
    sysctl_conntrack_max = ""
    probe(server,
      %Q{sh -c "sysctl #{conntrack_module_name}"}) do |result, status|
      raise FailedProbeCommandError, "Can't probe the server to obtain conntrack_max value using sysctl" unless status == 0
      puts "conntrack_max value returned by sysctl: #{result}"
      sysctl_conntrack_max = result
      true
    end
    sysctl_conntrack_max
  end

  # Verify the conntrack_max kernel parameter is set properly
  #
  # @param server [RightScale::ServerInterface] the server to verify for
  #   conntrack_max value
  #
  # @raise [ConntrackMaxError] if the value for conntrack_max is not set
  #   properly
  #
  def verify_conntrack_max(server)
    # Test 1: Verify the correct conntrack_max value is set in sysctl from
    # configuration file.
    #
    # Obtain the conntrack_max value set in the /etc/sysctl.conf
    conf_conntrack_max = obtain_conf_conntrack_max(server)

    # Obtain the conntrack_max value returned by the sysctl command
    sysctl_conntrack_max_before = obtain_sysctl_conntrack_max(server)

    if conf_conntrack_max == sysctl_conntrack_max_before
      puts "conntrack_max value is set properly"
    else
      raise ConntrackMaxError, "conntrack_max value is not set properly." +
        " #{conf_conntrack_max} != #{sysctl_conntrack_max_before}"
    end

    # Test 2: Verify that the value doesn't get reset when an iptables rule is
    # added or removed (iptables gets reloaded).
    #
    # Set a new port as input for sys_firewall::setup_rule. A port that is not
    # already opened should be used for the setup_rule recipe to rebuild
    # iptables. Port 8088 is not used anywhere and commonly used for test
    # purposes.
    #
    server.set_inputs("sys_firewall/rule/port" => "text:8088")

    # Run sys_firewall::setup_rule recipe. Running this recipe will rebuild
    # iptables.
    #
    run_recipe("sys_firewall::setup_rule", s_one)

    # Vefify that conntrack_max value is unchanged (not reset).
    # Obtain the conntrack_max value returned by the sysctl command after
    # running the sys_firewall::setup_rule recipe.
    #
    sysctl_conntrack_max_after = obtain_sysctl_conntrack_max(server)

    if sysctl_conntrack_max_before == sysctl_conntrack_max_after
      puts "conntrack_max value is unchanged after running" +
        " sys_firewall::setup_rule recipe"
    else
      raise ConntrackMaxError, "conntrack_max value is changed after running" +
        " sys_firewall::setup_rule recipe"
    end
  end

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
            " running on #{server.nickname}"
        end
        if response.include?("running")
          puts "The #{agent} agent is running on #{server.nickname}"
        else
          raise RackspaceRackManagedError, "The #{agent} agent is not running" +
            " on #{server.nickname} Current status is #{response}"
        end
        true
      end
    end
  end

  # Verifies the security repositories are unfrozen.
  #
  # For apt based systems (Ubuntu) it checks repositories in
  # /etc/apt/sources.list.d/rightscale.sources.list
  # For yum based systems (CentOS) it checks repositories in
  # /etc/yum.repos.d/*.repo
  #
  # @param server [Server] the server to obtain value from
  #
  # @raise [FrozenRepoError] if unfrozen repositories not found
  #
  def verify_security_repositories_unfrozen(server)
    # Check that unforzen repos exist in the package repo dir
    os = get_operating_system(server)
    puts "  Testing OS: #{os}"
    case os
    when /ubuntu/i
      latest = "/ubuntu_daily/latest"
      repo_dirs = "/etc/apt/sources.list.d/rightscale.sources.list "
    when /centos|rhel|redhat/i
      latest = "/archive/latest"
      repo_dirs = "/etc/yum.repos.d/*.repo"
    end

    probe(server, "grep #{latest} #{repo_dirs}") do |response, status|
      raise FrozenRepoError, "Unfrozen repo not found in " +
        "#{repo_dirs}" unless status == 0
      true
    end
  end
end

# Generic before all
#
# This does nothing at this time.  It is here to make it easier
# to debug missing specific test befores.
#
before do
  puts "  No before all actions"
end

# Before tests that require security updates disabled.
#
# Verify the server input rightscale/security_updates is set to "disable"
# Rackspace Managed Open clouds should have Rackspace credentials set.
#
before "smoke_test", "stop_start", "enable_security_updates_on_running_server",
  "ephemeral_file_system_type" do
  puts "Running before with security updates disabled"
  # Assume a single server in the deployment
  server = servers.first

  # Get the current cloud.
  cloud = Cloud.factory

  # Set the required credential inputs for Rackspace Managed cloud.
  setup_rackspace_managed_credentials(server) \
    if cloud.cloud_name =~ /Rackmanaged/

  if is_chef?
    # Verify the instance launched with the correct inputs.
    status = verify_instance_input_settings?(
      server,
      {"rightscale/security_updates" => "text:disable"}
    )

    relaunch_server(server) unless status
  else
    # RSB does not require input settings.  Just ensure the server
    # is operational.
    relaunch_server(server) if server.state != "operational"
  end

  wait_for_server_state(server, "operational")
end

# Before tests that require security updates enabled.
#
# Verify the server input rightscale/security_updates is set to "enable"
#
before "enable_security_updates_on_boot" do
  # Assume a single server in the deployment
  server = servers.first

  # Get the current cloud.
  cloud = Cloud.factory

  # Set the required credential inputs for Rackspace Managed cloud.
  setup_rackspace_managed_credentials(server) \
    if cloud.cloud_name =~ /Rackmanaged/

  if is_chef?
    # Verify the instance launched with the correct inputs.
    status = verify_instance_input_settings?(
      server,
      {"rightscale/security_updates" => "text:enable"}
    )

    relaunch_server(server) unless status
  else
    # RSB does not require input settings.  Just ensure the server
    # is operational.
    relaunch_server(server) if server.state != "operational"
  end

  wait_for_server_state(server, "operational")
end

# The Base smoke test makes sure the Base (Chef or RSB) ServerTemplate has its
# basic functionality including setting up any ephemeral volumes, setting up a
# swap file, basic monitoring, and the conntrack_max connection tracking
# parameter setup. It checks if this functionality is working after initial boot
# and then after a single reboot.
#
test_case "smoke_test" do
  # Get current cloud.
  cloud = Cloud.factory

  # Single server in deployment.
  server = servers.first

  # Ephemeral and swap file support are currently only implemented on the Chef
  # ServerTemplate.
  #
  if is_chef?
    check_ephemeral_mount(server) if cloud.supports_ephemeral?(server)
    check_swap_file(server)
    verify_conntrack_max(server)
    verify_rackspace_managed_agents(server) if cloud.cloud_name =~ /Rackmanaged/
  end

  # Check if the server's basic monitoring is working.
  check_monitoring

  # Reboot to check if functionality works after a reboot on clouds that
  # support reboot.
  if cloud.supports_reboot?
    reboot_all
    wait_for_all("operational")
  else
    puts "Reboot is not supported in this cloud. Skipping..."
  end

  # Ephemeral and swap file support are currently only implemented on the Chef
  # ServerTemplate.
  #
  if is_chef?
    check_ephemeral_mount(server) if cloud.supports_ephemeral?(server)
    check_swap_file(server)
    verify_conntrack_max(server)
    verify_rackspace_managed_agents(server) if cloud.cloud_name =~ /Rackmanaged/
  end

  # Check if the server's basic monitoring is working.
  check_monitoring

  # Check if security updates are disabled can not be done.  Servers can
  # can be launched with unfrozen repositories.  This case was considered
  # and it was decided to ignore it.
  #
end

# The Base stop/start test makes sure the Base (Chef or RSB) ServerTemplate has
# its basic functionality after a server has been stopped and then started
# again. The functionality it tests includes setting up any ephemeral volumes,
# setting up a swap file, basic monitoring, and the conntrack_max connection
# tracking parameter setup.
#
test_case "stop_start" do
  # Get the current cloud.
  cloud = Cloud.factory

  # Single server in deployment.
  server = servers.first

  # Only some clouds support stop/start.
  skip unless cloud.supports_stop_start?(server)

  # Stop server.
  puts "Stopping current server."
  server.stop_ebs
  wait_for_server_state(server, "stopped")

  # Start server.
  puts "Starting current server."
  server.start_ebs
  wait_for_server_state(server, "operational")
  # It takes about a minute for ips to get repopulated.
  wait_for_ip_repopulation(server)

  # Remove the public IP address tag if the cloud requires SSHing on the private
  # IP address.
  #
  server.remove_tags ["server:public_ip_0=#{server.public_ip}"] if cloud.needs_private_ssh?

  # Ephemeral, swap file support, and conntrack_max parameter are currently only
  # implemented on the Chef ServerTemplate.
  #
  if is_chef?
    check_ephemeral_mount(server) if cloud.supports_ephemeral?(server)
    check_swap_file(server)
    verify_conntrack_max(server)
  end

  # Check if the server's basic monitoring is working.
  check_monitoring
end

# The Base ephemeral_file_system_type test makes sure the file system type
# installed on the ephemeral drive is same as the type set in
# "block_device/ephemeral/file_system_type" input in the advanced inputs
# category of block device in Base Chef ServerTemplate.
#
test_case "ephemeral_file_system_type" do
  # Get the current cloud.
  cloud = Cloud.factory

  # Get the single server in the deployment.
  server = servers.first

  # Skip this test if the cloud does not support ephemeral drives and if the
  # ServerTemplate is not chef based. Ephemeral drives are supported only on
  # Chef ServerTemplates.
  skip unless cloud.supports_ephemeral?(server) && is_chef?

  # Get the OS used by the server
  os = get_operating_system(server)

  # List all file system types supported on the ephemeral device
  supported_fs_types = ["xfs", "ext3"]

  # We do not support xfs on Google cloud and Redhat due to these reasons
  # * Google uses a statically compiled kernel built without xfs support
  # * Redhat charges for using xfs. Hence we don't install it through our
  # cookbooks and tools.
  xfs_unsupported = os =~ /rhel/i || cloud.cloud_name == "Google"

  # Remove file system types that are not supported on the ephemeral device
  # based on the platform
  if xfs_unsupported
    unsupported_types = ["xfs"]
  else
    unsupported_types = []
  end

  # Get the list of supported file system types on the ephemeral device
  # based on the platform
  supported_fs_types = supported_fs_types - unsupported_types

  # Verify the default file system type that will be installed on the
  # ephemeral device
  default_fs_type = xfs_unsupported ? "ext3" : "xfs"
  verify_ephemeral_file_system_type(server, default_fs_type)
  supported_fs_types.delete(default_fs_type)

  # Iterate through the rest of the supported file system types and verify the
  # installation of each type
  supported_fs_types.each do |type|
    server.set_next_inputs({
      "block_device/ephemeral/file_system_type" => "text:#{type}"
    })
    relaunch_all
    verify_ephemeral_file_system_type(server, type)
  end
end

# The Base "enable security updates on running a running server" tests if
# security updates are applied after enabling them.  It enables the updates
# runs the script to perform the security updates setup and runs the script
# to perform the updates.
#
test_case "enable_security_updates_on_running_server" do
  if is_chef?
    server = servers.first
    server.set_inputs("rightscale/security_updates" => "text:enable")
    run_recipe("rightscale::setup_security_updates", server)
    verify_security_repositories_unfrozen(server)
    run_recipe("rightscale::do_security_updates", server)
  else
    puts "  RSB template - skipping enable_security_updates_on_running_server test"
  end
end

# The Base "verify repository unfrozen" test verfies the package managers
# upstream security repositories are set to "latest".
#
test_case "enable_security_updates_on_boot" do
  if is_chef?
    server = servers.first
    verify_security_repositories_unfrozen(server)
  else
    puts "  RSB template - skipping enable_security_updates_on_boot test"
  end
end
